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

    QString C_USER_AGENT        = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13G34 Instagram 8.5.2 (iPhone5,2; iPhone OS 9_3_3; es_ES; es-ES; scale=2.00; 640x1136)";

    // New
    QString USER_AGENT          = "Instagram 85.0.0.21.100 Android (24/7.0; 640dpi; 1440x2560; HUAWEI; LON-L29; HWLON; hi3660)";
    QString IG_SIG_KEY          = "937463b5272b5d60e9d20f0f8d7d192193dd95095a3ad43725d494300a5ea5fc";

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
