#ifndef INSTAGRAMREQUEST_H
#define INSTAGRAMREQUEST_H

#include <QDir>
#include <QNetworkAccessManager>
#include <QObject>

class InstagramRequest : public QObject
{
    Q_OBJECT
public:
    explicit InstagramRequest(QObject *parent = 0);

    void request(QString endpoint, QByteArray post, bool apiV2 = false, bool isGet = false);
    void fileRquest(QString endpoint, QString boundary, QByteArray data);
    void directRquest(QString endpoint, QString boundary, QByteArray data);
    void timelineRequest(QString endpoint, QByteArray post, QString uuid, bool apiV2 = false, bool isGet = false);
    QString generateSignature(QJsonObject data);
    QString buildBody(QList<QList<QString> > bodies, QString boundary);

private:
    QString API_URL             = "https://i.instagram.com/api/v1/";
    QString API_URL2            = "https://i.instagram.com/api/v2/";

    // New
    QString USER_AGENT          = "Instagram 24.0.0.12.201 Android (10/29; 560dpi; 2759x1440; SM-N975F; samsung; samsung; d2s; en_US)";
    QString IG_SIG_KEY          = "109513c04303341a7daf27bb41b268e633b30dcc65a3fe14503f743176113869";

    QString SIG_KEY_VERSION     = "4";
    QString X_IG_CAPABILITIES   = "3brTvw==";

    QDir m_data_path;

    QNetworkAccessManager *m_manager;
    QNetworkReply *m_reply;
    QNetworkCookieJar *m_jar;

signals:
    void replySrtingReady(QVariant ans);

    void progressReady(double ans);

public slots:

private slots:
    void finishGetUrl();
    void saveCookie();

    void progressChanged(qint64 a, qint64 b);
};

#endif // INSTAGRAMREQUEST_H
