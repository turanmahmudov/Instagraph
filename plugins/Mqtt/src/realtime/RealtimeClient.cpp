#include "RealtimeClient.h"
#include "../mqttot/MqttotClient.h"
#include "../thrift/ThriftCompact.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QUuid>
#include <QDateTime>
#include <QRegularExpression>
#include <QDebug>

namespace IGMQTT {

// Connection constants
const QString RealtimeClient::HOST = QStringLiteral("edge-mqtt.facebook.com");
const quint16 RealtimeClient::PORT = 443;
const quint16 RealtimeClient::KEEP_ALIVE = 20;
const qint64  RealtimeClient::APP_ID = 567067343352427LL;

// Topic IDs
const QString RealtimeClient::TOPIC_GRAPHQL = QStringLiteral("9");
const QString RealtimeClient::TOPIC_PUBSUB = QStringLiteral("88");
const QString RealtimeClient::TOPIC_FOREGROUND_STATE = QStringLiteral("102");
const QString RealtimeClient::TOPIC_SEND_MESSAGE = QStringLiteral("132");
const QString RealtimeClient::TOPIC_SEND_MSG_RESPONSE = QStringLiteral("133");
const QString RealtimeClient::TOPIC_IRIS_SUB = QStringLiteral("134");
const QString RealtimeClient::TOPIC_IRIS_SUB_RESPONSE = QStringLiteral("135");
const QString RealtimeClient::TOPIC_MESSAGE_SYNC = QStringLiteral("146");
const QString RealtimeClient::TOPIC_REALTIME_SUB = QStringLiteral("149");
const QString RealtimeClient::TOPIC_REGION_HINT = QStringLiteral("150");

// GraphQL QueryIDs
const QString RealtimeClient::QUERY_APP_PRESENCE = QStringLiteral("17846944882223835");
const QString RealtimeClient::QUERY_DIRECT_TYPING = QStringLiteral("17867973967082385");
const QString RealtimeClient::QUERY_DIRECT_STATUS = QStringLiteral("17854499065530643");

RealtimeClient::RealtimeClient(QObject* parent)
    : QObject(parent)
    , m_mqtt(new MqttotClient(this))
    , m_reconnectTimer(new QTimer(this))
    , m_connected(false)
    , m_irisSeqId(0)
    , m_irisSnapshotAtMs(0)
{
    m_reconnectTimer->setInterval(5000); // 5s reconnect delay
    m_reconnectTimer->setSingleShot(true);

    connect(m_mqtt, &MqttotClient::connected, this, &RealtimeClient::onMqttConnected);
    connect(m_mqtt, &MqttotClient::disconnected, this, &RealtimeClient::onMqttDisconnected);
    connect(m_mqtt, &MqttotClient::messageReceived, this, &RealtimeClient::onMqttMessage);
    connect(m_mqtt, &MqttotClient::error, this, &RealtimeClient::onMqttError);
    connect(m_reconnectTimer, &QTimer::timeout, this, &RealtimeClient::onReconnectTimer);
}

RealtimeClient::~RealtimeClient()
{
    disconnect();
}

void RealtimeClient::connectWithSession(const QString& userId, const QString& sessionId,
                                         const QString& phoneId, const QString& userAgent,
                                         const QString& appVersion, const QString& igCapabilities)
{
    m_userId = userId;
    m_sessionId = sessionId;
    m_phoneId = phoneId;
    m_userAgent = userAgent;
    m_appVersion = appVersion;
    m_igCapabilities = igCapabilities;

    QByteArray payload = buildConnectPayload();
    m_mqtt->connectToHost(HOST, PORT, payload, KEEP_ALIVE);
}

void RealtimeClient::disconnect()
{
    m_reconnectTimer->stop();
    m_mqtt->disconnectFromHost();
    m_connected = false;
}

bool RealtimeClient::isConnected() const
{
    return m_connected;
}

void RealtimeClient::subscribeToIris(qint64 seqId, qint64 snapshotAtMs)
{
    m_irisSeqId = seqId;
    m_irisSnapshotAtMs = snapshotAtMs;

    if (!m_connected) return;

    QJsonObject irisReq;
    irisReq["seq_id"] = static_cast<double>(seqId);
    irisReq["snapshot_at_ms"] = static_cast<double>(snapshotAtMs);
    irisReq["snapshot_app_version"] = m_appVersion;

    QByteArray json = QJsonDocument(irisReq).toJson(QJsonDocument::Compact);
    publishToTopic(TOPIC_IRIS_SUB, json);

    qDebug() << "RealtimeClient: IRIS subscription sent, seqId=" << seqId;
}

void RealtimeClient::subscribeToDirectTyping()
{
    if (!m_connected || m_userId.isEmpty()) return;

    QString sub = QString("1/graphqlsubscriptions/%1/{\"input_data\":{\"user_id\":\"%2\"}}")
                  .arg(QUERY_DIRECT_TYPING, m_userId);
    subscribeGraphQl(QStringList() << sub);
}

void RealtimeClient::subscribeToAppPresence()
{
    if (!m_connected) return;

    QString clientSubId = QUuid::createUuid().toString().remove('{').remove('}');
    QString sub = QString("1/graphqlsubscriptions/%1/{\"input_data\":{\"client_subscription_id\":\"%2\"}}")
                  .arg(QUERY_APP_PRESENCE, clientSubId);
    subscribeGraphQl(QStringList() << sub);
}

void RealtimeClient::subscribeToDirectStatus()
{
    if (!m_connected) return;

    QString clientSubId = QUuid::createUuid().toString().remove('{').remove('}');
    QString sub = QString("1/graphqlsubscriptions/%1/{\"input_data\":{\"client_subscription_id\":\"%2\"}}")
                  .arg(QUERY_DIRECT_STATUS, clientSubId);
    subscribeGraphQl(QStringList() << sub);
}

void RealtimeClient::subscribeToUserEvents()
{
    if (!m_connected || m_userId.isEmpty()) return;

    QString sub = QString("ig/u/v1/%1").arg(m_userId);
    subscribeSkywalker(QStringList() << sub);
}

void RealtimeClient::sendForegroundState(bool inForeground)
{
    if (!m_connected) return;

    // Encode foreground state as thrift (prefixed with 0x00 byte)
    Thrift::Writer w;
    // Start with 0x00 prefix byte
    QByteArray prefix;
    prefix.append(static_cast<char>(0x00));

    w.writeStructBegin();
    w.writeBool(1, inForeground);  // inForegroundApp
    w.writeBool(2, inForeground);  // inForegroundDevice
    w.writeInt32(3, inForeground ? 60 : 900);  // keepAliveTimeout
    w.writeStructEnd();

    publishToTopic(TOPIC_FOREGROUND_STATE, prefix + w.data());
}

// ============================================================
// MQTT signal handlers
// ============================================================

void RealtimeClient::onMqttConnected(const QByteArray& connAckPayload)
{
    Q_UNUSED(connAckPayload);
    qDebug() << "RealtimeClient: MQTT connected";
    m_connected = true;
    m_reconnectTimer->stop();

    // Send foreground state
    sendForegroundState(true);

    // Subscribe to user events via Skywalker
    subscribeToUserEvents();

    // Subscribe to GraphQL events
    subscribeToDirectTyping();
    subscribeToAppPresence();
    subscribeToDirectStatus();

    // Re-subscribe to IRIS if we have a seq_id
    if (m_irisSeqId > 0) {
        subscribeToIris(m_irisSeqId, m_irisSnapshotAtMs);
    }

    emit connectionStateChanged(true);
}

void RealtimeClient::onMqttDisconnected()
{
    qDebug() << "RealtimeClient: MQTT disconnected";
    m_connected = false;
    emit connectionStateChanged(false);

    // Auto-reconnect
    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
}

void RealtimeClient::onMqttMessage(const QString& topic, const QByteArray& payload)
{
    if (topic == TOPIC_MESSAGE_SYNC) {
        handleMessageSync(payload);
    } else if (topic == TOPIC_REALTIME_SUB) {
        handleRealtimeSub(payload);
    } else if (topic == TOPIC_PUBSUB) {
        handlePubsub(payload);
    } else if (topic == TOPIC_SEND_MSG_RESPONSE) {
        handleSendMessageResponse(payload);
    } else if (topic == TOPIC_IRIS_SUB_RESPONSE) {
        handleIrisSubResponse(payload);
    } else {
        qDebug() << "RealtimeClient: message on topic" << topic << "size=" << payload.size();
    }
}

void RealtimeClient::onMqttError(const QString& message)
{
    qWarning() << "RealtimeClient: error:" << message;
    emit error(message);

    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
}

void RealtimeClient::onReconnectTimer()
{
    if (!m_connected && !m_userId.isEmpty()) {
        qDebug() << "RealtimeClient: attempting reconnect";
        connectWithSession(m_userId, m_sessionId, m_phoneId,
                           m_userAgent, m_appVersion, m_igCapabilities);
    }
}

// ============================================================
// Thrift payload building
// ============================================================

QByteArray RealtimeClient::buildConnectPayload()
{
    qDebug() << "RealtimeClient: building CONNECT payload:"
             << "userId=" << m_userId
             << "sessionId=" << (m_sessionId.isEmpty() ? "EMPTY" : m_sessionId.left(10) + "...")
             << "phoneId=" << m_phoneId;

    Thrift::Writer w;
    w.writeStructBegin(); // Connect struct

    // Field 1: clientIdentifier (phone_id truncated to 20 chars)
    QString clientId = m_phoneId.left(20);
    w.writeString(1, clientId);

    // Field 4: clientInfo (nested struct)
    w.writeStructFieldBegin(4);
    w.writeStructBegin();
    {
        // userId (field 1, i64)
        w.writeInt64(1, m_userId.toLongLong());

        // userAgent (field 2, string)
        w.writeString(2, m_userAgent);

        // clientCapabilities (field 3, i64) = 183
        w.writeInt64(3, 183);

        // endpointCapabilities (field 4, i64) = 0
        w.writeInt64(4, 0);

        // publishFormat (field 5, i32) = 1
        w.writeInt32(5, 1);

        // noAutomaticForeground (field 6, bool) = false
        w.writeBool(6, false);

        // makeUserAvailableInForeground (field 7, bool) = true
        w.writeBool(7, true);

        // deviceId (field 8, string) = phoneId
        w.writeString(8, m_phoneId);

        // isInitiallyForeground (field 9, bool) = true
        w.writeBool(9, true);

        // networkType (field 10, i32) = 1 (WiFi)
        w.writeInt32(10, 1);

        // networkSubtype (field 11, i32) = 0
        w.writeInt32(11, 0);

        // clientMqttSessionId (field 12, i64) = current time & 0xFFFFFFFF
        qint64 sessionId = QDateTime::currentMSecsSinceEpoch() & 0xFFFFFFFF;
        w.writeInt64(12, sessionId);

        // subscribeTopics (field 14, list<i32>)
        // [88, 135, 149, 150, 133, 146]
        QVector<qint32> topics;
        topics << 88 << 135 << 149 << 150 << 133 << 146;
        w.writeListInt32(14, topics);

        // clientType (field 15, string) = "cookie_auth"
        w.writeString(15, QStringLiteral("cookie_auth"));

        // appId (field 16, i64) = 567067343352427
        w.writeInt64(16, APP_ID);

        // deviceSecret (field 20, string) = "" (empty for cookie auth)
        w.writeString(20, QString());

        // clientStack (field 21, byte) = 3
        w.writeByte(21, 3);
    }
    w.writeStructEnd(); // end clientInfo

    // Field 5: password = "sessionid=<sessionId>"
    w.writeString(5, QStringLiteral("sessionid=%1").arg(m_sessionId));

    // Field 10: appSpecificInfo (map<string,string>)
    QMap<QString, QString> appInfo;
    appInfo["app_version"] = m_appVersion;
    appInfo["X-IG-Capabilities"] = m_igCapabilities;
    appInfo["User-Agent"] = m_userAgent;
    appInfo["Accept-Language"] = QStringLiteral("en-US");
    appInfo["platform"] = QStringLiteral("android");
    appInfo["ig_mqtt_route"] = QStringLiteral("django");
    appInfo["pubsub_msg_type_blacklist"] = QStringLiteral("direct, typing_type");
    appInfo["auth_cache_enabled"] = QStringLiteral("0");

    // everclear_subscriptions for in-app notifications
    QJsonObject everclear;
    everclear["inapp_notification_subscribe_comment"] = "17899377895239777";
    everclear["inapp_notification_subscribe_comment_mention_and_reply"] = "17899377895239777";
    everclear["video_call_participant_state_delivery"] = "17977239895057311";
    everclear["presence_subscribe"] = "17846944882223835";
    appInfo["everclear_subscriptions"] = QString::fromUtf8(
        QJsonDocument(everclear).toJson(QJsonDocument::Compact));

    w.writeMapStringString(10, appInfo);

    w.writeStructEnd(); // end Connect struct

    return w.data();
}

// ============================================================
// Subscription helpers
// ============================================================

void RealtimeClient::subscribeGraphQl(const QStringList& subscriptions)
{
    QJsonObject obj;
    QJsonArray subArray;
    for (const QString& sub : subscriptions) {
        subArray.append(sub);
    }
    obj["sub"] = subArray;

    QByteArray json = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    publishToTopic(TOPIC_REALTIME_SUB, json);
}

void RealtimeClient::subscribeSkywalker(const QStringList& subscriptions)
{
    QJsonObject obj;
    QJsonArray subArray;
    for (const QString& sub : subscriptions) {
        subArray.append(sub);
    }
    obj["sub"] = subArray;

    QByteArray json = QJsonDocument(obj).toJson(QJsonDocument::Compact);
    publishToTopic(TOPIC_PUBSUB, json);
}

void RealtimeClient::publishToTopic(const QString& topicId, const QByteArray& payload)
{
    if (m_mqtt) {
        m_mqtt->publish(topicId, payload, 1);
    }
}

// ============================================================
// Message handlers
// ============================================================

void RealtimeClient::handleMessageSync(const QByteArray& payload)
{
    // IRIS message sync -- JSON array of patches
    QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (!doc.isArray()) {
        qWarning() << "RealtimeClient: invalid IRIS payload (not array)";
        return;
    }

    QVariantList patches = doc.array().toVariantList();
    emit irisDataReceived(patches);
    processIrisPatches(patches);
}

void RealtimeClient::handleRealtimeSub(const QByteArray& payload)
{
    // Can be either JSON or Thrift binary
    if (!payload.isEmpty() && (payload.at(0) == '{' || payload.at(0) == '[')) {
        // JSON format
        QJsonDocument doc = QJsonDocument::fromJson(payload);
        if (doc.isObject()) {
            QVariantMap data = doc.object().toVariantMap();
            QString topic = data.value("topic").toString();

            // Parse nested payload if present
            QVariant payloadField = data.value("payload");
            QVariantMap parsedPayload;
            if (payloadField.type() == QVariant::String) {
                QJsonDocument nestedDoc = QJsonDocument::fromJson(payloadField.toString().toUtf8());
                if (nestedDoc.isObject()) {
                    parsedPayload = nestedDoc.object().toVariantMap();
                }
            }

            if (topic == "direct") {
                emit directStatusEvent(parsedPayload.isEmpty() ? data : parsedPayload);
            } else if (topic == QUERY_DIRECT_TYPING) {
                emit typingIndicator(parsedPayload.isEmpty() ? data : parsedPayload);
            } else if (topic == QUERY_APP_PRESENCE) {
                emit appPresenceEvent(parsedPayload.isEmpty() ? data : parsedPayload);
            } else if (topic == QUERY_DIRECT_STATUS) {
                emit directStatusEvent(parsedPayload.isEmpty() ? data : parsedPayload);
            }
        }
    } else {
        // Thrift binary format
        QVariantMap parsed = parseGraphqlThrift(payload);
        if (!parsed.isEmpty()) {
            QString topic = parsed.value("topic").toString();

            // Parse nested payload JSON
            QVariantMap parsedPayload;
            QString payloadStr = parsed.value("payload").toString();
            if (!payloadStr.isEmpty()) {
                QJsonDocument nestedDoc = QJsonDocument::fromJson(payloadStr.toUtf8());
                if (nestedDoc.isObject()) {
                    parsedPayload = nestedDoc.object().toVariantMap();
                }
            }

            if (topic == "direct") {
                emit directStatusEvent(parsedPayload.isEmpty() ? parsed : parsedPayload);
            } else if (topic == QUERY_DIRECT_TYPING) {
                emit typingIndicator(parsedPayload.isEmpty() ? parsed : parsedPayload);
            } else if (topic == QUERY_APP_PRESENCE) {
                emit appPresenceEvent(parsedPayload.isEmpty() ? parsed : parsedPayload);
            } else if (topic == QUERY_DIRECT_STATUS) {
                emit directStatusEvent(parsedPayload.isEmpty() ? parsed : parsedPayload);
            }
        }
    }
}

void RealtimeClient::handlePubsub(const QByteArray& payload)
{
    // Skywalker events -- thrift binary
    QVariantMap parsed = parseSkywalkerThrift(payload);
    if (!parsed.isEmpty()) {
        emit userEvent(parsed);
    }
}

void RealtimeClient::handleSendMessageResponse(const QByteArray& payload)
{
    // JSON response after sending a DM
    QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (doc.isObject()) {
        qDebug() << "RealtimeClient: send message response received";
    }
}

void RealtimeClient::handleIrisSubResponse(const QByteArray& payload)
{
    QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        bool succeeded = obj.value("succeeded").toBool();
        qDebug() << "RealtimeClient: IRIS subscription" << (succeeded ? "succeeded" : "failed");
    }
}

// ============================================================
// IRIS patch processing
// ============================================================

void RealtimeClient::processIrisPatches(const QVariantList& patches)
{
    for (const QVariant& patchVar : patches) {
        QVariantMap patch = patchVar.toMap();
        QVariantList dataList = patch.value("data").toList();

        // Track seq_id for reconnection
        QVariant seqIdVar = patch.value("seq_id");
        if (seqIdVar.isValid()) {
            m_irisSeqId = seqIdVar.toLongLong();
        }

        for (const QVariant& dataVar : dataList) {
            QVariantMap data = dataVar.toMap();
            QString op = data.value("op").toString();
            QString path = data.value("path").toString();
            QString valueStr = data.value("value").toString();

            // Parse the value JSON if present
            QVariantMap value;
            if (!valueStr.isEmpty()) {
                QJsonDocument valDoc = QJsonDocument::fromJson(valueStr.toUtf8());
                if (valDoc.isObject()) {
                    value = valDoc.object().toVariantMap();
                }
            }

            // Check path patterns
            // /direct_v2/threads/<threadId>/items/<itemId> => new message
            // /direct_v2/threads/<threadId> => thread update
            // /direct_v2/inbox/threads/<threadId> => inbox thread update
            QRegularExpression messagePattern(
                QStringLiteral("^/direct_v2/threads/(\\d+)/items/(\\d+)$"));
            QRegularExpression threadPattern(
                QStringLiteral("^/direct_v2/threads/(\\d+)$"));
            QRegularExpression inboxThreadPattern(
                QStringLiteral("^/direct_v2/inbox/threads/(\\d+)$"));

            auto messageMatch = messagePattern.match(path);
            auto threadMatch = threadPattern.match(path);
            auto inboxThreadMatch = inboxThreadPattern.match(path);

            if (messageMatch.hasMatch() && !value.isEmpty()) {
                // New direct message
                QVariantMap msgData;
                msgData["threadId"] = messageMatch.captured(1);
                msgData["itemId"] = messageMatch.captured(2);
                msgData["op"] = op;
                msgData["message"] = value;
                msgData["seqId"] = patch.value("seq_id");
                msgData["mutationToken"] = patch.value("mutation_token");
                emit directMessageReceived(msgData);
            } else if (threadMatch.hasMatch() || inboxThreadMatch.hasMatch()) {
                // Thread-level update
                QString threadId = threadMatch.hasMatch()
                    ? threadMatch.captured(1)
                    : inboxThreadMatch.captured(1);

                QVariantMap threadData;
                threadData["threadId"] = threadId;
                threadData["op"] = op;
                threadData["path"] = path;
                threadData["data"] = value;
                emit directThreadUpdated(threadData);
            }
        }
    }
}

// ============================================================
// Thrift response parsing
// ============================================================

QVariantMap RealtimeClient::parseGraphqlThrift(const QByteArray& data)
{
    QVariantMap result;
    Thrift::Reader reader(data);
    reader.readStructBegin();

    int fieldId;
    Thrift::Type fieldType;
    while (reader.readFieldHeader(fieldId, fieldType)) {
        switch (fieldId) {
        case 1: // topic (BINARY)
            if (fieldType == Thrift::T_BINARY) {
                result["topic"] = reader.readString();
            } else {
                reader.skip(fieldType);
            }
            break;
        case 2: // payload (BINARY)
            if (fieldType == Thrift::T_BINARY) {
                result["payload"] = reader.readString();
            } else {
                reader.skip(fieldType);
            }
            break;
        default:
            reader.skip(fieldType);
            break;
        }
    }
    reader.readStructEnd();
    return result;
}

QVariantMap RealtimeClient::parseSkywalkerThrift(const QByteArray& data)
{
    QVariantMap result;
    Thrift::Reader reader(data);
    reader.readStructBegin();

    int fieldId;
    Thrift::Type fieldType;
    while (reader.readFieldHeader(fieldId, fieldType)) {
        switch (fieldId) {
        case 1: // topic (INT_32)
            if (fieldType == Thrift::T_INT32) {
                result["topic"] = reader.readInt32();
            } else {
                reader.skip(fieldType);
            }
            break;
        case 2: // payload (BINARY)
            if (fieldType == Thrift::T_BINARY) {
                result["payload"] = reader.readString();
            } else {
                reader.skip(fieldType);
            }
            break;
        default:
            reader.skip(fieldType);
            break;
        }
    }
    reader.readStructEnd();
    return result;
}

} // namespace IGMQTT
