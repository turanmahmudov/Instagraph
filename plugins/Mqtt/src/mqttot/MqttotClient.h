#ifndef MQTT_MQTTOT_CLIENT_H
#define MQTT_MQTTOT_CLIENT_H

#include <QByteArray>
#include <QMap>
#include <QObject>
#include <QSslSocket>
#include <QTimer>

namespace IGMQTT {

/**
 * @brief Low-level MQTToT (MQTT over Thrift) client.
 *
 * Implements Instagram's custom MQTT variant that uses:
 * - Protocol name "MQTToT" instead of "MQTT"
 * - Protocol level 3
 * - Thrift compact protocol payload instead of standard MQTT fields
 * - Zlib compression on all payloads
 * - TLS on port 443
 */
class MqttotClient : public QObject {
    Q_OBJECT

public:
    explicit MqttotClient(QObject * parent = nullptr);
    ~MqttotClient();

    // Connection
    void connectToHost(const QString & host, quint16 port, const QByteArray & thriftPayload,
                       quint16 keepAlive);
    void disconnectFromHost();
    bool isConnected() const;

    // MQTT operations
    void publish(const QString & topic, const QByteArray & payload, quint8 qos = 1);
    void subscribe(const QString & topic, quint8 qos = 0);

signals:
    void connected(const QByteArray & connAckPayload);
    void disconnected();
    void messageReceived(const QString & topic, const QByteArray & payload);
    void error(const QString & message);
    void connectionRefused(int returnCode);
    void publishAcknowledged(quint16 messageId);

private slots:
    void onSocketConnected();
    void onSocketDisconnected();
    void onSocketError(QAbstractSocket::SocketError error);
    void onReadyRead();
    void onPingTimer();

private:
    // Packet building
    QByteArray buildConnectPacket(const QByteArray & thriftPayload, quint16 keepAlive);
    QByteArray buildPublishPacket(const QString & topic, const QByteArray & payload, quint8 qos,
                                  quint16 msgId);
    QByteArray buildSubscribePacket(const QString & topic, quint8 qos, quint16 msgId);
    QByteArray buildPingReqPacket();
    QByteArray buildDisconnectPacket();
    QByteArray buildPubAckPacket(quint16 msgId);

    // Packet parsing
    void processIncomingData();
    void handlePacket(quint8 packetType, quint8 flags, const QByteArray & payload);
    void handleConnAck(const QByteArray & payload);
    void handlePublish(quint8 flags, const QByteArray & payload);
    void handlePubAck(const QByteArray & payload);
    void handleSubAck(const QByteArray & payload);
    void handlePingResp();

    // Helpers
    static QByteArray encodeVariableByteInt(quint32 value);
    static quint32 decodeVariableByteInt(const QByteArray & data, int & bytesUsed);
    void sendPacket(const QByteArray & packet);
    quint16 nextMessageId();

    // Compression
    static QByteArray zlibCompress(const QByteArray & data);
    static QByteArray zlibDecompress(const QByteArray & data);

    QSslSocket * m_socket;
    QTimer * m_pingTimer;
    QByteArray m_readBuffer;
    quint16 m_nextMsgId;
    quint16 m_keepAlive;
    bool m_connected;
};

} // namespace IGMQTT

#endif // MQTT_MQTTOT_CLIENT_H
