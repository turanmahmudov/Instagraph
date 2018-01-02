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

    void request(QString endpoint, QByteArray post, bool apiV2 = false);
    void fileRquest(QString endpoint, QString boundary, QByteArray data);
    void directRquest(QString endpoint, QString boundary, QByteArray data);
    QString generateSignature(QJsonObject data);
    QString buildBody(QList<QList<QString> > bodies, QString boundary);

private:
    QString API_URL             = "https://i.instagram.com/api/v1/";
    QString API_URL2            = "https://i.instagram.com/api/v2/";
    QString USER_AGENT          = "Instagram 10.15.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)";
    QString C_USER_AGENT        = "Mozilla/5.0 (iPhone; CPU iPhone OS 9_3_3 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13G34 Instagram 8.5.2 (iPhone5,2; iPhone OS 9_3_3; es_ES; es-ES; scale=2.00; 640x1136)";
    QString IG_SIG_KEY          = "b03e0daaf2ab17cda2a569cace938d639d1288a1197f9ecf97efd0a4ec0874d7";
    QString SIG_KEY_VERSION     = "4";
    QString X_IG_CAPABILITIES   = "3R4=";

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
