#ifndef MQTT_INSTAGRAM_MQTT_H
#define MQTT_INSTAGRAM_MQTT_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>

namespace IGMQTT {
    class FbnsClient;
}

/**
 * @brief QML-facing facade for Instagram FBNS push notifications.
 *
 * Emits a single pushNotificationReceived signal with parsed notification data.
 * The notification QVariantMap contains: collapseKey, title, message,
 * igAction, optionalImage, optionalAvatarUrl, sound, pushId, pushCategory,
 * sourceUserId, intendedRecipientUserId, tickerText, badgeCount.
 *
 * QML should switch on collapseKey to handle different notification types.
 */
class InstagramMqtt : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool fbnsConnected READ isFbnsConnected NOTIFY fbnsConnectionChanged)

public:
    explicit InstagramMqtt(QObject* parent = nullptr);
    ~InstagramMqtt();

    bool isFbnsConnected() const;

public slots:
    Q_INVOKABLE void connectToMqtt(const QString& userId, const QString& phoneId);
    Q_INVOKABLE void disconnectFromMqtt();

signals:
    void fbnsConnectionChanged(bool connected);
    void mqttError(const QString& message);
    void fbnsTokenReceived(const QString& token);
    void pushNotificationReceived(const QVariant& notification);

private:
    IGMQTT::FbnsClient* m_fbns;
};

#endif // MQTT_INSTAGRAM_MQTT_H
