#include "FbnsClient.h"
#include "../mqttot/MqttotClient.h"
#include "../thrift/ThriftCompact.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QDebug>

namespace IGMQTT {

// Connection constants
const QString FbnsClient::HOST = QStringLiteral("mqtt-mini.facebook.com");
const quint16 FbnsClient::PORT = 443;
const quint16 FbnsClient::KEEP_ALIVE = 60;
const qint64  FbnsClient::FBNS_APP_ID = 567310203415052LL;
const QString FbnsClient::PACKAGE_NAME = QStringLiteral("com.instagram.android");
const QString FbnsClient::ANALYTICS_APP_ID = QStringLiteral("567067343352427");

// Topic IDs
const QString FbnsClient::TOPIC_FBNS_MSG = QStringLiteral("76");
const QString FbnsClient::TOPIC_FBNS_REG_REQ = QStringLiteral("79");
const QString FbnsClient::TOPIC_FBNS_REG_RESP = QStringLiteral("80");

FbnsClient::FbnsClient(QObject* parent)
    : QObject(parent)
    , m_mqtt(new MqttotClient(this))
    , m_reconnectTimer(new QTimer(this))
    , m_connected(false)
{
    m_reconnectTimer->setInterval(30000); // 30s reconnect delay
    m_reconnectTimer->setSingleShot(true);

    connect(m_mqtt, &MqttotClient::connected, this, &FbnsClient::onMqttConnected);
    connect(m_mqtt, &MqttotClient::disconnected, this, &FbnsClient::onMqttDisconnected);
    connect(m_mqtt, &MqttotClient::messageReceived, this, &FbnsClient::onMqttMessage);
    connect(m_mqtt, &MqttotClient::error, this, &FbnsClient::onMqttError);
    connect(m_reconnectTimer, &QTimer::timeout, this, &FbnsClient::onReconnectTimer);

    loadAuth();
}

FbnsClient::~FbnsClient()
{
    disconnect();
}

void FbnsClient::connectWithSession(const QString& userId, const QString& phoneId,
                                     const QString& userAgent, const QString& appId)
{
    m_igUserId = userId;
    m_igPhoneId = phoneId;
    m_igUserAgent = userAgent;
    m_igAppId = appId;

    // Generate client ID if not persisted: first 20 chars of phoneId
    if (m_auth.clientId.isEmpty()) {
        m_auth.clientId = phoneId.left(20);
    }

    QByteArray payload = buildConnectPayload();
    m_mqtt->connectToHost(HOST, PORT, payload, KEEP_ALIVE);
}

void FbnsClient::disconnect()
{
    m_reconnectTimer->stop();
    m_mqtt->disconnectFromHost();
    m_connected = false;
}

bool FbnsClient::isConnected() const
{
    return m_connected;
}

// ============================================================
// MQTT signal handlers
// ============================================================

void FbnsClient::onMqttConnected(const QByteArray& connAckPayload)
{
    qDebug() << "FbnsClient: connected";
    m_connected = true;
    m_reconnectTimer->stop();

    // Parse CONNACK auth payload (JSON with ck, cs, di, ds)
    if (!connAckPayload.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(connAckPayload);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            // ck can be a JSON number, so use toVariant().toString() to handle both
            m_auth.userId = obj.value("ck").toVariant().toString();
            m_auth.password = obj.value("cs").toVariant().toString();
            m_auth.deviceId = obj.value("di").toVariant().toString();
            m_auth.deviceSecret = obj.value("ds").toVariant().toString();
            m_auth.sr = obj.value("sr").toVariant().toString();
            m_auth.rc = obj.value("rc").toVariant().toString();

            if (!m_auth.deviceId.isEmpty()) {
                m_auth.clientId = m_auth.deviceId.left(20);
            }

            saveAuth();
        }
    }

    // Subscribe to FBNS message topic for receiving push notifications
    m_mqtt->subscribe(TOPIC_FBNS_MSG, 0);

    // Send registration request
    sendRegistrationRequest();

    emit connectionStateChanged(true);
}

void FbnsClient::onMqttDisconnected()
{
    qDebug() << "FbnsClient: MQTT disconnected";
    m_connected = false;
    emit connectionStateChanged(false);

    // Auto-reconnect
    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
}

void FbnsClient::onMqttMessage(const QString& topic, const QByteArray& payload)
{

    if (topic == TOPIC_FBNS_MSG) {
        handleFbnsMessage(payload);
    } else if (topic == TOPIC_FBNS_REG_RESP) {
        handleRegistrationResponse(payload);
    }
}

void FbnsClient::onMqttError(const QString& message)
{
    qWarning() << "FbnsClient: error:" << message;
    emit error(message);

    // Try reconnect
    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
}

void FbnsClient::onReconnectTimer()
{
    if (!m_connected && !m_igUserId.isEmpty()) {
        qDebug() << "FbnsClient: attempting reconnect";
        connectWithSession(m_igUserId, m_igPhoneId, m_igUserAgent, m_igAppId);
    }
}

// ============================================================
// Thrift payload building
// ============================================================

QByteArray FbnsClient::buildConnectPayload()
{

    Thrift::Writer w;
    w.writeStructBegin(); // Connect struct

    // Field 1: clientIdentifier
    w.writeString(1, m_auth.clientId);

    // Field 4: clientInfo (nested struct)
    w.writeStructFieldBegin(4);
    w.writeStructBegin();
    {
        // userId (field 1, i64)
        qint64 userId = m_auth.userId.isEmpty() ? 0 : m_auth.userId.toLongLong();
        w.writeInt64(1, userId);

        // userAgent (field 2, string)
        // Build FBNS-specific user agent
        QString fbnsUA = QStringLiteral(
            "[FBAN/MQTT;FBAV/%1;FBBV/%2;"
            "FBDM/{density=4.0,width=1440,height=2560};"
            "FBLC/en_US;FBCR/;FBMF/samsung;FBBD/samsung;"
            "FBPN/com.instagram.android;FBDV/SM-S938U;"
            "FBSV/15.0;FBLR/0;FBBK/1;FBCA/arm64-v8a;]"
        ).arg("367.0.0.27.101", "658859659");
        w.writeString(2, fbnsUA);

        // clientCapabilities (field 3, i64) = 183
        w.writeInt64(3, 183);

        // endpointCapabilities (field 4, i64) = 128
        w.writeInt64(4, 128);

        // publishFormat (field 5, i32) = 1
        w.writeInt32(5, 1);

        // noAutomaticForeground (field 6, bool) = true
        w.writeBool(6, true);

        // makeUserAvailableInForeground (field 7, bool) = false
        w.writeBool(7, false);

        // deviceId (field 8, string) - empty on first connect, server returns it in CONNACK
        w.writeString(8, m_auth.deviceId);

        // isInitiallyForeground (field 9, bool) = false
        w.writeBool(9, false);

        // networkType (field 10, i32) = 1 (WiFi)
        w.writeInt32(10, 1);

        // networkSubtype (field 11, i32) = 0
        w.writeInt32(11, 0);

        // clientMqttSessionId (field 12, i64) = Date.now() & 0xFFFFFFFF
        w.writeInt64(12, QDateTime::currentMSecsSinceEpoch() & 0xFFFFFFFF);

        // subscribeTopics (field 14, list<i32>) = [76, 80, 231]
        QVector<qint32> topics;
        topics << 76 << 80 << 231;
        w.writeListInt32(14, topics);

        // clientType (field 15, string) = "device_auth"
        w.writeString(15, QStringLiteral("device_auth"));

        // appId (field 16, i64) = 567310203415052
        w.writeInt64(16, FBNS_APP_ID);

        // deviceSecret (field 20, string)
        w.writeString(20, m_auth.deviceSecret);

        // clientStack (field 21, byte) = 3
        w.writeByte(21, 3);

        // anotherUnknown (field 26, i64) = -1
        w.writeInt64(26, -1);
    }
    w.writeStructEnd(); // end clientInfo

    // Field 5: password
    w.writeString(5, m_auth.password);

    w.writeStructEnd(); // end Connect struct

    return w.data();
}

void FbnsClient::sendRegistrationRequest()
{
    QJsonObject regReq;
    regReq["pkg_name"] = PACKAGE_NAME;
    regReq["appid"] = ANALYTICS_APP_ID;

    QByteArray json = QJsonDocument(regReq).toJson(QJsonDocument::Compact);
    m_mqtt->publish(TOPIC_FBNS_REG_REQ, json, 1);
}

void FbnsClient::handleFbnsMessage(const QByteArray& payload)
{
    QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (!doc.isObject()) {
        qWarning() << "FbnsClient: invalid FBNS message payload";
        return;
    }

    QJsonObject push = doc.object();
    QVariantMap pushData = push.toVariantMap();

    // Parse the nested fbpushnotif JSON
    QString fbpushnotif = push.value("fbpushnotif").toString();
    if (!fbpushnotif.isEmpty()) {
        QJsonDocument notifDoc = QJsonDocument::fromJson(fbpushnotif.toUtf8());
        if (notifDoc.isObject()) {
            QVariantMap notifData = notifDoc.object().toVariantMap();
            pushData["notification"] = notifData;
            parseAndEmitNotification(notifData);
        }
    }

    emit pushNotification(pushData);
}

void FbnsClient::handleRegistrationResponse(const QByteArray& payload)
{
    QJsonDocument doc = QJsonDocument::fromJson(payload);
    if (!doc.isObject()) {
        qWarning() << "FbnsClient: invalid registration response";
        return;
    }

    QJsonObject resp = doc.object();
    QString errorStr = resp.value("error").toString();
    if (!errorStr.isEmpty()) {
        qWarning() << "FbnsClient: registration error:" << errorStr;
        return;
    }

    QString token = resp.value("token").toString();
    if (!token.isEmpty()) {
        qDebug() << "FbnsClient: token received";
        emit tokenReceived(token);
    }
}

void FbnsClient::parseAndEmitNotification(const QVariantMap& notifData)
{
    // Build a structured notification
    QVariantMap notification;
    notification["title"] = notifData.value("t");
    notification["message"] = notifData.value("m");
    notification["tickerText"] = notifData.value("tt");
    notification["igAction"] = notifData.value("ig");
    notification["collapseKey"] = notifData.value("collapse_key");
    notification["optionalImage"] = notifData.value("i");
    notification["optionalAvatarUrl"] = notifData.value("a");
    notification["sound"] = notifData.value("sound");
    notification["pushId"] = notifData.value("pi");
    notification["pushCategory"] = notifData.value("c");
    notification["intendedRecipientUserId"] = notifData.value("u");
    notification["sourceUserId"] = notifData.value("s");
    notification["badgeCount"] = notifData.value("bc");

    // Route to specific signal based on collapse_key
    QString collapseKey = notifData.value("collapse_key").toString();

    if (collapseKey == "direct_v2_message") {
        emit directMessageNotification(notification);
    } else if (collapseKey == "like" || collapseKey == "like_on_tag" || collapseKey == "comment_like") {
        emit likeNotification(notification);
    } else if (collapseKey == "comment" || collapseKey == "mentioned_comment" ||
               collapseKey == "comment_on_tag" || collapseKey == "reply_to_comment_with_threading") {
        emit commentNotification(notification);
    } else if (collapseKey == "new_follower" || collapseKey == "private_user_follow_request" ||
               collapseKey == "follow_request_approved") {
        emit followNotification(notification);
    } else if (collapseKey == "usertag") {
        emit mentionNotification(notification);
    }
}

// ============================================================
// Auth persistence
// ============================================================

QString FbnsClient::authFilePath() const
{
    QString cachePath = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(cachePath);
    return cachePath + "/fbns_auth.json";
}

void FbnsClient::saveAuth()
{
    QJsonObject obj;
    obj["ck"] = m_auth.userId;
    obj["cs"] = m_auth.password;
    obj["di"] = m_auth.deviceId;
    obj["ds"] = m_auth.deviceSecret;
    obj["ci"] = m_auth.clientId;
    obj["sr"] = m_auth.sr;
    obj["rc"] = m_auth.rc;

    QFile file(authFilePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(obj).toJson(QJsonDocument::Compact));
        file.close();
    }
}

void FbnsClient::loadAuth()
{
    QFile file(authFilePath());
    if (!file.open(QIODevice::ReadOnly)) return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    if (!doc.isObject()) return;

    QJsonObject obj = doc.object();
    m_auth.userId = obj.value("ck").toString();
    m_auth.password = obj.value("cs").toString();
    m_auth.deviceId = obj.value("di").toString();
    m_auth.deviceSecret = obj.value("ds").toString();
    m_auth.clientId = obj.value("ci").toString();
    m_auth.sr = obj.value("sr").toString();
    m_auth.rc = obj.value("rc").toString();
}

} // namespace IGMQTT
