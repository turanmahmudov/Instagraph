#ifndef INSTAGRAPH_DISKCACHENETWORKACCESSMANAGERFACTORY_H
#define INSTAGRAPH_DISKCACHENETWORKACCESSMANAGERFACTORY_H

#include <QMutex>
#include <QQmlNetworkAccessManagerFactory>

// Qt calls create() from the GUI thread and from the image loader thread. Two QNetworkDiskCache
// instances must not share a directory.
class DiskCacheNetworkAccessManagerFactory : public QQmlNetworkAccessManagerFactory {
public:
    QNetworkAccessManager * create(QObject * parent) override;

private:
    QMutex m_mutex;
    int m_threadManagerCount = 0;
};

#endif // INSTAGRAPH_DISKCACHENETWORKACCESSMANAGERFACTORY_H
