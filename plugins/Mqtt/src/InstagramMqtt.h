#ifndef MQTT_INSTAGRAM_MQTT_H
#define MQTT_INSTAGRAM_MQTT_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>

namespace IGMQTT {
    class FbnsClient;
}

/**
 * @brief QML-facing facade for Instagram MQTT services.
 *
 * Provides push notifications (FBNS) to QML.
 *
 * Usage in QML:
 *   import InstagramMqtt 1.0
 *
 *   InstagramMqtt {
 *       id: mqtt
 *   }
 *
 *   // After login:
 *   mqtt.connect(userId, sessionId, phoneId, userAgent, appVersion, igCapabilities)
 *
 *   Connections {
 *       target: mqtt
 *       onDmNotification: { console.log("New DM:", JSON.stringify(data)) }
 *       onLikeNotification: { console.log("New like:", JSON.stringify(data)) }
 *   }
 */
class InstagramMqtt : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool fbnsConnected READ isFbnsConnected NOTIFY fbnsConnectionChanged)

public:
    explicit InstagramMqtt(QObject* parent = nullptr);
    ~InstagramMqtt();

    bool isFbnsConnected() const;

public slots:
    /**
     * @brief Connect FBNS MQTT client for push notifications.
     * Call this after successful Instagram login.
     */
    Q_INVOKABLE void connectToMqtt(const QString& userId, const QString& sessionId,
                                    const QString& phoneId, const QString& userAgent,
                                    const QString& appVersion, const QString& igCapabilities);

    /**
     * @brief Disconnect FBNS client.
     */
    Q_INVOKABLE void disconnectFromMqtt();

signals:
    // Connection state
    void fbnsConnectionChanged(bool connected);
    void mqttError(const QString& message);

    // ============ FBNS Push Notifications ============

    /** @brief Raw push notification data (all types) */
    void pushNotificationReceived(const QVariant& notification);

    /** @brief New DM notification (collapse_key = "direct_v2_message") */
    void dmNotification(const QVariant& data);

    /** @brief Like notification (collapse_key = "like", "like_on_tag", "comment_like") */
    void likeNotification(const QVariant& data);

    /** @brief Comment notification */
    void commentNotification(const QVariant& data);

    /** @brief New follower / follow request notification */
    void followNotification(const QVariant& data);

    /** @brief Mention/tag notification */
    void mentionNotification(const QVariant& data);

    /** @brief FBNS push token received (for push/register API endpoint) */
    void fbnsTokenReceived(const QString& token);

private:
    IGMQTT::FbnsClient* m_fbns;
};

#endif // MQTT_INSTAGRAM_MQTT_H
