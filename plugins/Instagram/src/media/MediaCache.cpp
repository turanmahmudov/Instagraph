#include "MediaCache.h"

#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QUrl>

MediaCache::MediaCache(QObject * parent)
    : QObject(parent), m_network(new QNetworkAccessManager(this)),
      m_cacheDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) + "/media") {
    m_cacheDir.mkpath(".");
}

QString MediaCache::fetch(const QString & url) {
    if (url.isEmpty()) {
        return QString();
    }

    const QString path = buildCachePath(url);
    if (QFile::exists(path)) {
        return QUrl::fromLocalFile(path).toString();
    }

    if (m_pending.contains(url)) {
        return QString();
    }
    m_pending.insert(url);

    QNetworkReply * reply = m_network->get(QNetworkRequest(QUrl(url)));
    connect(reply, &QNetworkReply::finished, this, [this, reply, url, path]() {
        reply->deleteLater();
        m_pending.remove(url);

        if (reply->error() != QNetworkReply::NoError) {
            return;
        }

        QFile file(path);
        if (file.open(QIODevice::WriteOnly)) {
            file.write(reply->readAll());
            file.close();
            emit fetched(url, QUrl::fromLocalFile(path).toString());
        }
    });

    return QString();
}

QString MediaCache::buildCachePath(const QString & url) const {
    // CDN URLs carry expiring signature parameters; the path identifies the file
    const QUrl parsed(url);
    const QByteArray key =
        QCryptographicHash::hash(parsed.path().toUtf8(), QCryptographicHash::Sha1).toHex();
    const QString suffix = QFileInfo(parsed.path()).suffix();
    return m_cacheDir.filePath(QString::fromLatin1(key) + (suffix.isEmpty() ? "" : "." + suffix));
}
