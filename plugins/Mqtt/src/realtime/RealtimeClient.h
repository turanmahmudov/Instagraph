#ifndef MQTT_REALTIME_CLIENT_H
#define MQTT_REALTIME_CLIENT_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QTimer>

namespace IGMQTT {

class MqttotClient;

/**
 * @brief Realtime MQTT client for live Instagram updates.
 *
 * Connects to edge-mqtt.facebook.com:443 using cookie_auth,
 * subscribes to IRIS message sync and GraphQL subscriptions
 * for live DM delivery, activity updates, typing indicators, etc.
 */
class RealtimeClient : public QObject {
    Q_OBJECT

public:
    explicit RealtimeClient(QObject* parent = nullptr);
    ~RealtimeClient();

    // Connection - requires session data from Instagram plugin
    void connectWithSession(const QString& userId, const QString& sessionId,
                            const QString& phoneId, const QString& userAgent,
                            const QString& appVersion, const QString& igCapabilities);
    void disconnect();
    bool isConnected() const;

    // IRIS message sync (DM updates)
    void subscribeToIris(qint64 seqId, qint64 snapshotAtMs);

    // GraphQL subscriptions
    void subscribeToDirectTyping();
    void subscribeToAppPresence();
    void subscribeToDirectStatus();

    // Skywalker (pubsub) subscriptions
    void subscribeToUserEvents();

    // Foreground state
    void sendForegroundState(bool inForeground);

signals:
    // Connection status
    void connectionStateChanged(bool connected);
    void error(const QString& message);

    // Direct messages (from IRIS sync)
    void directMessageReceived(const QVariantMap& message);
    void directThreadUpdated(const QVariantMap& threadUpdate);

    // GraphQL subscription events
    void typingIndicator(const QVariantMap& data);
    void appPresenceEvent(const QVariantMap& data);
    void directStatusEvent(const QVariantMap& data);

    // Skywalker/pubsub events
    void userEvent(const QVariantMap& data);

    // Raw IRIS data (for debugging / future use)
    void irisDataReceived(const QVariantList& patches);

private slots:
    void onMqttConnected(const QByteArray& connAckPayload);
    void onMqttDisconnected();
    void onMqttMessage(const QString& topic, const QByteArray& payload);
    void onMqttError(const QString& message);
    void onReconnectTimer();

private:
    // Thrift payload building
    QByteArray buildConnectPayload();

    // Subscription helpers
    void subscribeGraphQl(const QStringList& subscriptions);
    void subscribeSkywalker(const QStringList& subscriptions);
    void publishToTopic(const QString& topicId, const QByteArray& payload);

    // Message handlers
    void handleMessageSync(const QByteArray& payload);
    void handleRealtimeSub(const QByteArray& payload);
    void handlePubsub(const QByteArray& payload);
    void handleSendMessageResponse(const QByteArray& payload);
    void handleIrisSubResponse(const QByteArray& payload);

    // IRIS patch processing
    void processIrisPatches(const QVariantList& patches);

    // Thrift response parsing
    QVariantMap parseGraphqlThrift(const QByteArray& data);
    QVariantMap parseSkywalkerThrift(const QByteArray& data);

    MqttotClient* m_mqtt;
    QTimer* m_reconnectTimer;
    bool m_connected;

    // Session data
    QString m_userId;
    QString m_sessionId;
    QString m_phoneId;
    QString m_userAgent;
    QString m_appVersion;
    QString m_igCapabilities;

    // IRIS state
    qint64 m_irisSeqId;
    qint64 m_irisSnapshotAtMs;

    // Constants
    static const QString HOST;
    static const quint16 PORT;
    static const quint16 KEEP_ALIVE;
    static const qint64 APP_ID;

    // Topic IDs
    static const QString TOPIC_GRAPHQL;           // "9"
    static const QString TOPIC_PUBSUB;            // "88"
    static const QString TOPIC_FOREGROUND_STATE;   // "102"
    static const QString TOPIC_SEND_MESSAGE;       // "132"
    static const QString TOPIC_SEND_MSG_RESPONSE;  // "133"
    static const QString TOPIC_IRIS_SUB;           // "134"
    static const QString TOPIC_IRIS_SUB_RESPONSE;  // "135"
    static const QString TOPIC_MESSAGE_SYNC;       // "146"
    static const QString TOPIC_REALTIME_SUB;       // "149"
    static const QString TOPIC_REGION_HINT;        // "150"

    // GraphQL QueryIDs
    static const QString QUERY_APP_PRESENCE;       // "17846944882223835"
    static const QString QUERY_DIRECT_TYPING;      // "17867973967082385"
    static const QString QUERY_DIRECT_STATUS;      // "17854499065530643"
};

} // namespace IGMQTT

#endif // MQTT_REALTIME_CLIENT_H
