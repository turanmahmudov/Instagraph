#include "MediaCache.h"

#include <QCryptographicHash>
#include <QFile>
#include <QFileInfo>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSaveFile>
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

        QSaveFile file(path);
        if (reply->error() != QNetworkReply::NoError || !file.open(QIODevice::WriteOnly)) {
            emit failed(url);
            return;
        }

        file.write(reply->readAll());
        if (!file.commit()) {
            emit failed(url);
            return;
        }
        emit fetched(url, QUrl::fromLocalFile(path).toString());
    });

    return QString();
}

QString MediaCache::saveToDownloads(const QString & localUrl) {
    const QString source = QUrl(localUrl).toLocalFile();
    const QDir downloads(QStandardPaths::writableLocation(QStandardPaths::DownloadLocation));
    if (!downloads.mkpath(".")) {
        return QString();
    }

    const QString target = downloads.filePath("instagraph_" + QFileInfo(source).fileName());
    if (QFile::exists(target)) {
        return target;
    }
    return QFile::copy(source, target) ? target : QString();
}

QString MediaCache::buildCachePath(const QString & url) const {
    // CDN URLs carry expiring signature parameters; the path identifies the file
    const QUrl parsed(url);
    const QByteArray key =
        QCryptographicHash::hash(parsed.path().toUtf8(), QCryptographicHash::Sha1).toHex();
    const QString suffix = QFileInfo(parsed.path()).suffix();
    return m_cacheDir.filePath(QString::fromLatin1(key) + (suffix.isEmpty() ? "" : "." + suffix));
}
