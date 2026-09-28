#ifndef INSTAGRAM_MEDIACACHE_H
#define INSTAGRAM_MEDIACACHE_H

#include <QDir>
#include <QNetworkAccessManager>
#include <QObject>
#include <QSet>
#include <QString>

// Saves remote media files to the cache directory. QML AnimatedImage in Qt 5.15 plays
// animated WebP only from local files.
class MediaCache : public QObject {
    Q_OBJECT
public:
    explicit MediaCache(QObject * parent = nullptr);

    // Returns the local file URL when the file is cached, otherwise starts the download
    // and returns an empty string
    Q_INVOKABLE QString fetch(const QString & url);

signals:
    void fetched(const QString & url, const QString & localUrl);

private:
    QString buildCachePath(const QString & url) const;

    QNetworkAccessManager * m_network;
    QDir m_cacheDir;
    QSet<QString> m_pending;
};

#endif // INSTAGRAM_MEDIACACHE_H
