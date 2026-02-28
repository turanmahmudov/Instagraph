#ifndef MQTT_INSTAGRAM_MQTT_H
#define MQTT_INSTAGRAM_MQTT_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>
#include <QVariantList>

namespace IGMQTT {
    class FbnsClient;
    class RealtimeClient;
}

/**
 * @brief QML-facing facade for Instagram MQTT services.
 *
 * Provides real-time push notifications (FBNS) and live activity
 * updates (Realtime IRIS + GraphQL subscriptions) to QML.
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
 *       onDirectMessageReceived: { console.log("New DM:", JSON.stringify(message)) }
 *       onLikeNotification: { console.log("New like:", JSON.stringify(data)) }
 *   }
 */
class InstagramMqtt : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool fbnsConnected READ isFbnsConnected NOTIFY fbnsConnectionChanged)
    Q_PROPERTY(bool realtimeConnected READ isRealtimeConnected NOTIFY realtimeConnectionChanged)

public:
    explicit InstagramMqtt(QObject* parent = nullptr);
    ~InstagramMqtt();

    bool isFbnsConnected() const;
    bool isRealtimeConnected() const;

public slots:
    /**
     * @brief Connect both FBNS and Realtime MQTT clients.
     * Call this after successful Instagram login.
     */
    Q_INVOKABLE void connectToMqtt(const QString& userId, const QString& sessionId,
                                    const QString& phoneId, const QString& userAgent,
                                    const QString& appVersion, const QString& igCapabilities);

    /**
     * @brief Disconnect both clients.
     */
    Q_INVOKABLE void disconnectFromMqtt();

    /**
     * @brief Start IRIS message sync for live DM delivery.
     * @param seqId Last known sequence ID (from getInbox response)
     * @param snapshotAtMs Snapshot timestamp in milliseconds
     */
    Q_INVOKABLE void startIrisSync(double seqId, double snapshotAtMs);

    /**
     * @brief Send foreground/background state to realtime server.
     * Call when app goes to foreground or background.
     */
    Q_INVOKABLE void setForeground(bool inForeground);

signals:
    // Connection state
    void fbnsConnectionChanged(bool connected);
    void realtimeConnectionChanged(bool connected);
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

    // ============ Realtime Live Updates ============

    /** @brief Live direct message received (from IRIS sync) */
    void directMessageReceived(const QVariant& message);

    /** @brief Direct thread updated (member changes, read state, etc.) */
    void directThreadUpdated(const QVariant& threadUpdate);

    /** @brief Typing indicator received */
    void typingIndicatorReceived(const QVariant& data);

    /** @brief User online/offline presence event */
    void presenceReceived(const QVariant& data);

    /** @brief Skywalker user event (generic) */
    void userEventReceived(const QVariant& data);

    /** @brief Raw IRIS patch data (for advanced processing) */
    void irisDataReceived(const QVariant& patches);

private:
    IGMQTT::FbnsClient* m_fbns;
    IGMQTT::RealtimeClient* m_realtime;
};

#endif // MQTT_INSTAGRAM_MQTT_H
