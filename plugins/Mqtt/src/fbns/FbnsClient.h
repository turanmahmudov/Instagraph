#ifndef MQTT_FBNS_CLIENT_H
#define MQTT_FBNS_CLIENT_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QTimer>

namespace IGMQTT {

class MqttotClient;

/**
 * @brief FBNS (Facebook Notification Service) client for push notifications.
 *
 * Connects to mqtt-mini.facebook.com:443 using device_auth,
 * registers for push notifications, and receives real-time notifications
 * for likes, comments, follows, DMs, etc.
 */
class FbnsClient : public QObject {
    Q_OBJECT

public:
    explicit FbnsClient(QObject* parent = nullptr);
    ~FbnsClient();

    // Connection - requires session data from Instagram plugin
    void connectWithSession(const QString& userId, const QString& phoneId,
                            const QString& userAgent, const QString& appId);
    void disconnect();
    bool isConnected() const;

signals:
    // Connection status
    void connectionStateChanged(bool connected);
    void error(const QString& message);

    // Push notifications (parsed)
    void pushNotification(const QVariantMap& notification);

    // Specific notification types for convenience
    void directMessageNotification(const QVariantMap& data);
    void likeNotification(const QVariantMap& data);
    void commentNotification(const QVariantMap& data);
    void followNotification(const QVariantMap& data);
    void mentionNotification(const QVariantMap& data);

    // FBNS token (for push/register API call)
    void tokenReceived(const QString& token);

private slots:
    void onMqttConnected(const QByteArray& connAckPayload);
    void onMqttDisconnected();
    void onMqttMessage(const QString& topic, const QByteArray& payload);
    void onMqttError(const QString& message);
    void onReconnectTimer();

private:
    // Thrift payload building
    QByteArray buildConnectPayload();
    void sendRegistrationRequest();
    void handleFbnsMessage(const QByteArray& payload);
    void handleRegistrationResponse(const QByteArray& payload);
    void parseAndEmitNotification(const QVariantMap& pushData);

    // Auth persistence
    void saveAuth();
    void loadAuth();
    QString authFilePath() const;

    // FBNS auth credentials (persisted across sessions)
    struct FbnsAuth {
        QString userId;      // "ck" - connection key
        QString password;    // "cs" - connection secret
        QString deviceId;    // "di"
        QString deviceSecret; // "ds"
        QString clientId;    // derived from deviceId
        QString sr;          // "sr" - session reset
        QString rc;          // "rc" - reconnect count
    };

    MqttotClient* m_mqtt;
    QTimer* m_reconnectTimer;
    FbnsAuth m_auth;
    bool m_connected;

    // Session data (from Instagram plugin)
    QString m_igUserId;
    QString m_igPhoneId;
    QString m_igUserAgent;
    QString m_igAppId;

    // Constants
    static const QString HOST;
    static const quint16 PORT;
    static const quint16 KEEP_ALIVE;
    static const qint64 FBNS_APP_ID;
    static const QString PACKAGE_NAME;
    static const QString ANALYTICS_APP_ID;

    // Topic IDs
    static const QString TOPIC_FBNS_MSG;     // "76"
    static const QString TOPIC_FBNS_REG_REQ; // "79"
    static const QString TOPIC_FBNS_REG_RESP; // "80"
};

} // namespace IGMQTT

#endif // MQTT_FBNS_CLIENT_H
