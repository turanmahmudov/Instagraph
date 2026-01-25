#include "cacheimage.h"

CacheImage::CacheImage(QObject *parent) : QObject(parent)
{
}

void CacheImage::init() {
    QDir::setCurrent(cacheLocation);
    QDir c(cacheLocation);
    if(!c.exists()){
        c.mkdir(cacheLocation);
    }
}

QString CacheImage::getFromCache(const QString &str, const QString &width){
    QUrl url(str);

    QDir cw(cacheLocation+"/"+width);
    if(!cw.exists()){
        cw.mkdir(cacheLocation+"/"+width);
    }

    QString path = cacheLocation+"/"+width+"/"+url.fileName();

    if(QFile::exists(path) && QFile(path).size()>0) {
        return "file://" + path;
    } else {
        downloaded=false;
        QDir::setCurrent(cacheLocation+"/"+width);
        output.setFileName(url.fileName());
        output.open(QIODevice::WriteOnly);
        requestImage(url);
        return "file://" + path;
    }
}

void CacheImage::requestImage(const QUrl &url){
    currentDownload = manager.get(QNetworkRequest(QUrl(url)));
    connect(currentDownload, SIGNAL(finished()),
            SLOT(downloadFinished()));
    connect(currentDownload, SIGNAL(readyRead()),
            SLOT(downloadReadyRead()));
    QEventLoop event;
    connect(currentDownload,SIGNAL(finished()),&event,SLOT(quit()));
    event.exec();
}

void CacheImage::downloadFinished()
{
    output.close();
    downloaded=true;
    if (currentDownload->error()) {
//TODO: add signals
    }
    currentDownload->deleteLater();
}

void CacheImage::downloadReadyRead()
{
    output.write(currentDownload->readAll());
    emit finished();
}

void CacheImage::clean(){
    QDir::setCurrent(cacheLocation);
    QDir dir(cacheLocation);
    if(dir.count()>10){
        dir.removeRecursively();
    }
}
