#include "MqttotClient.h"
#include <QDebug>
#include <QSslConfiguration>
#include <cstring>
#include <zlib.h>

namespace IGMQTT {

// MQTT command types
static const quint8 MQTT_CONNECT = 0x10;
static const quint8 MQTT_CONNACK = 0x20;
static const quint8 MQTT_PUBLISH = 0x30;
static const quint8 MQTT_PUBACK = 0x40;
static const quint8 MQTT_SUBSCRIBE = 0x80;
static const quint8 MQTT_SUBACK = 0x90;
static const quint8 MQTT_PINGREQ = 0xC0;
static const quint8 MQTT_PINGRESP = 0xD0;
static const quint8 MQTT_DISCONNECT = 0xE0;

MqttotClient::MqttotClient(QObject * parent)
    : QObject(parent), m_socket(new QSslSocket(this)), m_pingTimer(new QTimer(this)),
      m_nextMsgId(1), m_keepAlive(60), m_connected(false) {
    // Configure TLS -- accept Instagram/Facebook certificates
    QSslConfiguration sslConfig = m_socket->sslConfiguration();
    sslConfig.setPeerVerifyMode(QSslSocket::VerifyPeer);
    sslConfig.setProtocol(QSsl::TlsV1_2OrLater);
    m_socket->setSslConfiguration(sslConfig);

    connect(m_socket, &QSslSocket::encrypted, this, &MqttotClient::onSocketConnected);
    connect(m_socket, &QSslSocket::disconnected, this, &MqttotClient::onSocketDisconnected);
    connect(m_socket, &QSslSocket::errorOccurred, this, &MqttotClient::onSocketError);
    connect(m_socket, &QSslSocket::readyRead, this, &MqttotClient::onReadyRead);
    connect(m_pingTimer, &QTimer::timeout, this, &MqttotClient::onPingTimer);
}

MqttotClient::~MqttotClient() {
    disconnectFromHost();
}

void MqttotClient::connectToHost(const QString & host, quint16 port,
                                 const QByteArray & thriftPayload, quint16 keepAlive) {
    m_keepAlive = keepAlive;
    m_readBuffer.clear();
    m_connected = false;

    // Store payload for sending after TLS handshake
    m_socket->setProperty("_connectPayload", thriftPayload);

    m_socket->connectToHostEncrypted(host, port);
}

void MqttotClient::disconnectFromHost() {
    m_pingTimer->stop();
    if (m_connected) {
        sendPacket(buildDisconnectPacket());
        m_connected = false;
    }
    if (m_socket->state() != QAbstractSocket::UnconnectedState) {
        m_socket->disconnectFromHost();
    }
}

bool MqttotClient::isConnected() const {
    return m_connected;
}

void MqttotClient::publish(const QString & topic, const QByteArray & payload, quint8 qos) {
    if (!m_connected) {
        qWarning() << "MqttotClient::publish: not connected";
        return;
    }

    // Compress payload
    QByteArray compressed = zlibCompress(payload);

    quint16 msgId = 0;
    if (qos > 0) {
        msgId = nextMessageId();
    }

    sendPacket(buildPublishPacket(topic, compressed, qos, msgId));
}

void MqttotClient::subscribe(const QString & topic, quint8 qos) {
    if (!m_connected) {
        qWarning() << "MqttotClient::subscribe: not connected";
        return;
    }
    quint16 msgId = nextMessageId();
    sendPacket(buildSubscribePacket(topic, qos, msgId));
}

// ============================================================
// Socket signal handlers
// ============================================================

void MqttotClient::onSocketConnected() {

    QByteArray thriftPayload = m_socket->property("_connectPayload").toByteArray();
    sendPacket(buildConnectPacket(thriftPayload, m_keepAlive));
}

void MqttotClient::onSocketDisconnected() {
    m_pingTimer->stop();
    m_connected = false;
    emit disconnected();
}

void MqttotClient::onSocketError(QAbstractSocket::SocketError err) {
    Q_UNUSED(err);
    QString msg = m_socket->errorString();
    qWarning() << "MqttotClient: socket error:" << msg;
    emit error(msg);
}

void MqttotClient::onReadyRead() {
    m_readBuffer.append(m_socket->readAll());
    processIncomingData();
}

void MqttotClient::onPingTimer() {
    if (m_connected) {
        sendPacket(buildPingReqPacket());
    }
}

// ============================================================
// Packet building
// ============================================================

QByteArray MqttotClient::buildConnectPacket(const QByteArray & thriftPayload, quint16 keepAlive) {
    // Compress the thrift payload
    QByteArray compressed = zlibCompress(thriftPayload);

    // Variable header: protocol name + version + flags + keepalive
    QByteArray variableHeader;
    // Protocol name "MQTToT" with 2-byte length prefix
    variableHeader.append(static_cast<char>(0x00));
    variableHeader.append(static_cast<char>(0x06));
    variableHeader.append("MQTToT", 6);
    // Protocol level 3
    variableHeader.append(static_cast<char>(0x03));
    // Connect flags: 0xC2 (username=1, password=1, cleanSession=1)
    variableHeader.append(static_cast<char>(0xC2));
    // Keep alive (big-endian 16-bit)
    variableHeader.append(static_cast<char>((keepAlive >> 8) & 0xFF));
    variableHeader.append(static_cast<char>(keepAlive & 0xFF));

    // Full payload = variable header + compressed thrift (no length prefix)
    QByteArray payload = variableHeader + compressed;

    // Build complete packet
    QByteArray packet;
    packet.append(static_cast<char>(MQTT_CONNECT));
    packet.append(encodeVariableByteInt(static_cast<quint32>(payload.size())));
    packet.append(payload);

    return packet;
}

QByteArray MqttotClient::buildPublishPacket(const QString & topic, const QByteArray & payload,
                                            quint8 qos, quint16 msgId) {
    QByteArray topicUtf8 = topic.toUtf8();

    QByteArray variableHeader;
    // Topic with 2-byte length prefix
    variableHeader.append(static_cast<char>((topicUtf8.size() >> 8) & 0xFF));
    variableHeader.append(static_cast<char>(topicUtf8.size() & 0xFF));
    variableHeader.append(topicUtf8);
    // Message ID (only for QoS > 0)
    if (qos > 0) {
        variableHeader.append(static_cast<char>((msgId >> 8) & 0xFF));
        variableHeader.append(static_cast<char>(msgId & 0xFF));
    }

    QByteArray fullPayload = variableHeader + payload;

    quint8 cmd = MQTT_PUBLISH | (qos << 1);
    QByteArray packet;
    packet.append(static_cast<char>(cmd));
    packet.append(encodeVariableByteInt(static_cast<quint32>(fullPayload.size())));
    packet.append(fullPayload);

    return packet;
}

QByteArray MqttotClient::buildSubscribePacket(const QString & topic, quint8 qos, quint16 msgId) {
    QByteArray topicUtf8 = topic.toUtf8();

    QByteArray payload;
    // Message ID
    payload.append(static_cast<char>((msgId >> 8) & 0xFF));
    payload.append(static_cast<char>(msgId & 0xFF));
    // Topic with 2-byte length prefix
    payload.append(static_cast<char>((topicUtf8.size() >> 8) & 0xFF));
    payload.append(static_cast<char>(topicUtf8.size() & 0xFF));
    payload.append(topicUtf8);
    // Subscribe options (QoS)
    payload.append(static_cast<char>(qos));

    QByteArray packet;
    packet.append(static_cast<char>(MQTT_SUBSCRIBE | 0x02)); // fixed flag 0x02
    packet.append(encodeVariableByteInt(static_cast<quint32>(payload.size())));
    packet.append(payload);

    return packet;
}

QByteArray MqttotClient::buildPingReqPacket() {
    QByteArray packet;
    packet.append(static_cast<char>(MQTT_PINGREQ));
    packet.append(static_cast<char>(0x00));
    return packet;
}

QByteArray MqttotClient::buildDisconnectPacket() {
    QByteArray packet;
    packet.append(static_cast<char>(MQTT_DISCONNECT));
    packet.append(static_cast<char>(0x00));
    return packet;
}

QByteArray MqttotClient::buildPubAckPacket(quint16 msgId) {
    QByteArray packet;
    packet.append(static_cast<char>(MQTT_PUBACK));
    packet.append(static_cast<char>(0x02));
    packet.append(static_cast<char>((msgId >> 8) & 0xFF));
    packet.append(static_cast<char>(msgId & 0xFF));
    return packet;
}

// ============================================================
// Packet parsing
// ============================================================

void MqttotClient::processIncomingData() {
    while (m_readBuffer.size() >= 2) {
        // Parse fixed header
        quint8 byte0 = static_cast<quint8>(m_readBuffer.at(0));
        quint8 packetType = byte0 & 0xF0;
        quint8 flags = byte0 & 0x0F;

        // Parse remaining length (variable byte integer)
        int bytesUsed = 0;
        quint32 remainingLength = 0;
        int multiplier = 1;
        bool lengthComplete = false;

        for (int i = 1; i < m_readBuffer.size() && i <= 4; ++i) {
            quint8 encodedByte = static_cast<quint8>(m_readBuffer.at(i));
            remainingLength += (encodedByte & 0x7F) * multiplier;
            multiplier *= 128;
            bytesUsed = i;
            if ((encodedByte & 0x80) == 0) {
                lengthComplete = true;
                break;
            }
        }

        if (!lengthComplete) {
            break; // Need more data for length
        }

        int headerSize = 1 + bytesUsed;
        int totalPacketSize = headerSize + static_cast<int>(remainingLength);

        if (m_readBuffer.size() < totalPacketSize) {
            break; // Need more data for full packet
        }

        // Extract packet payload
        QByteArray payload = m_readBuffer.mid(headerSize, static_cast<int>(remainingLength));
        m_readBuffer.remove(0, totalPacketSize);

        handlePacket(packetType, flags, payload);
    }
}

void MqttotClient::handlePacket(quint8 packetType, quint8 flags, const QByteArray & payload) {
    switch (packetType) {
    case MQTT_CONNACK:
        handleConnAck(payload);
        break;
    case MQTT_PUBLISH:
        handlePublish(flags, payload);
        break;
    case MQTT_PUBACK:
        handlePubAck(payload);
        break;
    case MQTT_SUBACK:
        handleSubAck(payload);
        break;
    case MQTT_PINGRESP:
        handlePingResp();
        break;
    default:
        break;
    }
}

void MqttotClient::handleConnAck(const QByteArray & payload) {
    if (payload.size() < 2) {
        emit error("Invalid CONNACK packet");
        return;
    }

    quint8 returnCode = static_cast<quint8>(payload.at(1));
    if (returnCode != 0) {
        emit error(QString("CONNACK rejected with code %1").arg(returnCode));
        emit connectionRefused(returnCode);
        return;
    }

    m_connected = true;

    // Start ping timer (keepalive/2 interval)
    m_pingTimer->start(m_keepAlive * 500);

    // Extract additional payload (beyond standard 2-byte CONNACK)
    // Instagram's CONNACK contains a 2-byte length-prefixed string after the
    // standard ack flags + return code bytes (matching TypeScript
    // readStringAsBuffer)
    QByteArray connAckPayload;
    if (payload.size() > 4) {
        // Read 2-byte big-endian length at offset 2
        quint16 strLen =
            (static_cast<quint8>(payload.at(2)) << 8) | static_cast<quint8>(payload.at(3));
        if (payload.size() >= 4 + strLen) {
            connAckPayload = payload.mid(4, strLen);
        } else {
            // Fallback: use everything after the length prefix
            connAckPayload = payload.mid(4);
        }
    }

    emit connected(connAckPayload);
}

void MqttotClient::handlePublish(quint8 flags, const QByteArray & payload) {
    if (payload.size() < 2)
        return;

    int pos = 0;

    // Read topic (2-byte length prefix)
    quint16 topicLen =
        (static_cast<quint8>(payload.at(pos)) << 8) | static_cast<quint8>(payload.at(pos + 1));
    pos += 2;

    if (pos + topicLen > payload.size())
        return;
    QString topic = QString::fromUtf8(payload.mid(pos, topicLen));
    pos += topicLen;

    // Read message ID for QoS > 0
    quint8 qos = (flags >> 1) & 0x03;
    quint16 msgId = 0;
    if (qos > 0) {
        if (pos + 2 > payload.size())
            return;
        msgId =
            (static_cast<quint8>(payload.at(pos)) << 8) | static_cast<quint8>(payload.at(pos + 1));
        pos += 2;

        // Send PUBACK
        sendPacket(buildPubAckPacket(msgId));
    }

    // Extract message payload
    QByteArray msgPayload = payload.mid(pos);

    // Try to decompress (check for zlib magic byte 0x78)
    QByteArray decompressed = zlibDecompress(msgPayload);
    if (!decompressed.isEmpty()) {
        msgPayload = decompressed;
    }

    emit messageReceived(topic, msgPayload);
}

void MqttotClient::handlePubAck(const QByteArray & payload) {
    if (payload.size() < 2)
        return;
    quint16 msgId = (static_cast<quint8>(payload.at(0)) << 8) | static_cast<quint8>(payload.at(1));
    emit publishAcknowledged(msgId);
}

void MqttotClient::handleSubAck(const QByteArray & payload) {
    Q_UNUSED(payload);
}

void MqttotClient::handlePingResp() {}

// ============================================================
// Helpers
// ============================================================

QByteArray MqttotClient::encodeVariableByteInt(quint32 value) {
    QByteArray result;
    do {
        quint8 encodedByte = value % 128;
        value /= 128;
        if (value > 0) {
            encodedByte |= 0x80;
        }
        result.append(static_cast<char>(encodedByte));
    } while (value > 0);
    return result;
}

quint32 MqttotClient::decodeVariableByteInt(const QByteArray & data, int & bytesUsed) {
    quint32 value = 0;
    quint32 multiplier = 1;
    bytesUsed = 0;

    for (int i = 0; i < data.size() && i < 4; ++i) {
        quint8 encodedByte = static_cast<quint8>(data.at(i));
        value += (encodedByte & 0x7F) * multiplier;
        multiplier *= 128;
        bytesUsed = i + 1;
        if ((encodedByte & 0x80) == 0)
            break;
    }

    return value;
}

void MqttotClient::sendPacket(const QByteArray & packet) {
    if (m_socket && m_socket->state() == QAbstractSocket::ConnectedState) {
        m_socket->write(packet);
        m_socket->flush();
    }
}

quint16 MqttotClient::nextMessageId() {
    quint16 id = m_nextMsgId;
    m_nextMsgId++;
    if (m_nextMsgId == 0)
        m_nextMsgId = 1;
    return id;
}

QByteArray MqttotClient::zlibCompress(const QByteArray & data) {
    if (data.isEmpty())
        return QByteArray();

    z_stream zs;
    memset(&zs, 0, sizeof(zs));

    if (deflateInit(&zs, 9) != Z_OK) {
        qWarning() << "MqttotClient: deflateInit failed";
        return QByteArray();
    }

    zs.next_in = reinterpret_cast<Bytef *>(const_cast<char *>(data.constData()));
    zs.avail_in = static_cast<uInt>(data.size());

    QByteArray result;
    char outBuffer[32768];

    do {
        zs.next_out = reinterpret_cast<Bytef *>(outBuffer);
        zs.avail_out = sizeof(outBuffer);

        int ret = deflate(&zs, Z_FINISH);
        if (ret == Z_STREAM_ERROR) {
            deflateEnd(&zs);
            return QByteArray();
        }

        result.append(outBuffer, static_cast<int>(sizeof(outBuffer) - zs.avail_out));
    } while (zs.avail_out == 0);

    deflateEnd(&zs);
    return result;
}

QByteArray MqttotClient::zlibDecompress(const QByteArray & data) {
    if (data.isEmpty())
        return QByteArray();

    // Check zlib magic byte
    if (static_cast<quint8>(data.at(0)) != 0x78) {
        return QByteArray(); // Not zlib compressed
    }

    z_stream zs;
    memset(&zs, 0, sizeof(zs));

    if (inflateInit(&zs) != Z_OK) {
        qWarning() << "MqttotClient: inflateInit failed";
        return QByteArray();
    }

    zs.next_in = reinterpret_cast<Bytef *>(const_cast<char *>(data.constData()));
    zs.avail_in = static_cast<uInt>(data.size());

    QByteArray result;
    char outBuffer[32768];

    do {
        zs.next_out = reinterpret_cast<Bytef *>(outBuffer);
        zs.avail_out = sizeof(outBuffer);

        int ret = inflate(&zs, Z_NO_FLUSH);
        if (ret == Z_STREAM_ERROR || ret == Z_DATA_ERROR || ret == Z_MEM_ERROR) {
            inflateEnd(&zs);
            return QByteArray();
        }

        result.append(outBuffer, static_cast<int>(sizeof(outBuffer) - zs.avail_out));

        if (ret == Z_STREAM_END)
            break;
    } while (zs.avail_out == 0);

    inflateEnd(&zs);
    return result;
}

} // namespace IGMQTT
