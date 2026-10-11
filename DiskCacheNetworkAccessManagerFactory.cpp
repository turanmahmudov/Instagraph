#include "DiskCacheNetworkAccessManagerFactory.h"

#include <QCoreApplication>
#include <QMutexLocker>
#include <QNetworkAccessManager>
#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QThread>

QNetworkAccessManager * DiskCacheNetworkAccessManagerFactory::create(QObject * parent) {
    QString directoryName = QStringLiteral("network-gui");
    if (QThread::currentThread() != QCoreApplication::instance()->thread()) {
        QMutexLocker locker(&m_mutex);
        directoryName = m_threadManagerCount == 0
                            ? QStringLiteral("network-images")
                            : QStringLiteral("network-images-%1").arg(m_threadManagerCount);
        ++m_threadManagerCount;
    }

    QNetworkAccessManager * manager = new QNetworkAccessManager(parent);
    QNetworkDiskCache * cache = new QNetworkDiskCache(manager);
    cache->setCacheDirectory(QStandardPaths::writableLocation(QStandardPaths::CacheLocation) +
                             QLatin1Char('/') + directoryName);
    manager->setCache(cache);
    return manager;
}
