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
    connect(m_fbns, &IGMQTT::FbnsClient::tokenReceived,
            this, &InstagramMqtt::fbnsTokenReceived);
    connect(m_fbns, &IGMQTT::FbnsClient::pushNotification, this,
            [this](const QVariantMap& n) { emit pushNotificationReceived(QVariant(n)); });
}

InstagramMqtt::~InstagramMqtt()
{
    disconnectFromMqtt();
}

bool InstagramMqtt::isFbnsConnected() const
{
    return m_fbns->isConnected();
}

void InstagramMqtt::connectToMqtt(const QString& userId, const QString& phoneId)
{
    qDebug() << "InstagramMqtt: connecting FBNS";
    m_fbns->connectWithSession(userId, phoneId);
}

void InstagramMqtt::disconnectFromMqtt()
{
    m_fbns->disconnect();
}
