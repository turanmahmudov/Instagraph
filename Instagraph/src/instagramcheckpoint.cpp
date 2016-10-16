#include <src/instagramcheckpoint.h>
#include <src/instagramrequest.h>

#include <QCryptographicHash>

#include <QFileInfo>
#include <QStandardPaths>
#include <QDateTime>
#include <QUuid>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDataStream>
#include <QUrl>

#include <QDebug>

InstagramCheckPoint::InstagramCheckPoint(QObject *parent)
    : QObject(parent)
{
    this->m_data_path =  QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    if(!m_data_path.exists())
    {
        m_data_path.mkpath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    }
}
