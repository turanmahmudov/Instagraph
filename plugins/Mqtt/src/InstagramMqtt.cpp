#include "InstagramMqtt.h"
#include "fbns/FbnsClient.h"

#include <QDebug>

InstagramMqtt::InstagramMqtt(QObject* parent)
    : QObject(parent)
    , m_fbns(new IGMQTT::FbnsClient(this))
{
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
}

InstagramMqtt::~InstagramMqtt()
{
    disconnectFromMqtt();
}

bool InstagramMqtt::isFbnsConnected() const
{
    return m_fbns->isConnected();
}

void InstagramMqtt::connectToMqtt(const QString& userId, const QString& sessionId,
                                   const QString& phoneId, const QString& userAgent,
                                   const QString& appVersion, const QString& igCapabilities)
{
    Q_UNUSED(sessionId)
    Q_UNUSED(appVersion)
    Q_UNUSED(igCapabilities)

    qDebug() << "InstagramMqtt: connecting FBNS";

    m_fbns->connectWithSession(userId, phoneId, userAgent,
                                QStringLiteral("567310203415052"));
}

void InstagramMqtt::disconnectFromMqtt()
{
    m_fbns->disconnect();
}
