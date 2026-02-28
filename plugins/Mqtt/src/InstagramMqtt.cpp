#include "InstagramMqtt.h"
#include "fbns/FbnsClient.h"
#include "realtime/RealtimeClient.h"

#include <QDebug>

InstagramMqtt::InstagramMqtt(QObject* parent)
    : QObject(parent)
    , m_fbns(new IGMQTT::FbnsClient(this))
    , m_realtime(new IGMQTT::RealtimeClient(this))
{
    // ============ FBNS connections ============

    connect(m_fbns, &IGMQTT::FbnsClient::connectionStateChanged,
            this, &InstagramMqtt::fbnsConnectionChanged);

    connect(m_fbns, &IGMQTT::FbnsClient::error,
            this, &InstagramMqtt::mqttError);

    connect(m_fbns, &IGMQTT::FbnsClient::pushNotification, this,
            [this](const QVariantMap& notification) {
                emit pushNotificationReceived(QVariant(notification));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::directMessageNotification, this,
            [this](const QVariantMap& data) {
                emit dmNotification(QVariant(data));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::likeNotification, this,
            [this](const QVariantMap& data) {
                emit likeNotification(QVariant(data));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::commentNotification, this,
            [this](const QVariantMap& data) {
                emit commentNotification(QVariant(data));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::followNotification, this,
            [this](const QVariantMap& data) {
                emit followNotification(QVariant(data));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::mentionNotification, this,
            [this](const QVariantMap& data) {
                emit mentionNotification(QVariant(data));
            });

    connect(m_fbns, &IGMQTT::FbnsClient::tokenReceived,
            this, &InstagramMqtt::fbnsTokenReceived);

    // ============ Realtime connections ============

    connect(m_realtime, &IGMQTT::RealtimeClient::connectionStateChanged,
            this, &InstagramMqtt::realtimeConnectionChanged);

    connect(m_realtime, &IGMQTT::RealtimeClient::error,
            this, &InstagramMqtt::mqttError);

    connect(m_realtime, &IGMQTT::RealtimeClient::directMessageReceived, this,
            [this](const QVariantMap& message) {
                emit directMessageReceived(QVariant(message));
            });

    connect(m_realtime, &IGMQTT::RealtimeClient::directThreadUpdated, this,
            [this](const QVariantMap& threadUpdate) {
                emit directThreadUpdated(QVariant(threadUpdate));
            });

    connect(m_realtime, &IGMQTT::RealtimeClient::typingIndicator, this,
            [this](const QVariantMap& data) {
                emit typingIndicatorReceived(QVariant(data));
            });

    connect(m_realtime, &IGMQTT::RealtimeClient::appPresenceEvent, this,
            [this](const QVariantMap& data) {
                emit presenceReceived(QVariant(data));
            });

    connect(m_realtime, &IGMQTT::RealtimeClient::userEvent, this,
            [this](const QVariantMap& data) {
                emit userEventReceived(QVariant(data));
            });

    connect(m_realtime, &IGMQTT::RealtimeClient::irisDataReceived, this,
            [this](const QVariantList& patches) {
                emit irisDataReceived(QVariant(patches));
            });
}

InstagramMqtt::~InstagramMqtt()
{
    disconnectFromMqtt();
}

bool InstagramMqtt::isFbnsConnected() const
{
    return m_fbns->isConnected();
}

bool InstagramMqtt::isRealtimeConnected() const
{
    return m_realtime->isConnected();
}

void InstagramMqtt::connectToMqtt(const QString& userId, const QString& sessionId,
                                   const QString& phoneId, const QString& userAgent,
                                   const QString& appVersion, const QString& igCapabilities)
{
    qDebug() << "InstagramMqtt: connecting with userId=" << userId;

    // Connect FBNS (push notifications)
    m_fbns->connectWithSession(userId, phoneId, userAgent,
                                QStringLiteral("567310203415052"));

    // Realtime disabled for now — focus on FBNS push notifications
    // m_realtime->connectWithSession(userId, sessionId, phoneId,
    //                                 userAgent, appVersion, igCapabilities);
}

void InstagramMqtt::disconnectFromMqtt()
{
    m_fbns->disconnect();
    m_realtime->disconnect();
}

void InstagramMqtt::startIrisSync(double seqId, double snapshotAtMs)
{
    m_realtime->subscribeToIris(static_cast<qint64>(seqId),
                                 static_cast<qint64>(snapshotAtMs));
}

void InstagramMqtt::setForeground(bool inForeground)
{
    m_realtime->sendForegroundState(inForeground);
}
