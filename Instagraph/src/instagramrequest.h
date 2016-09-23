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

    void request(QString endpoint, QByteArray post);
    void fileRquest(QString endpoint, QString boundary, QByteArray data);
    void directRquest(QString endpoint, QString boundary, QByteArray data);
    QString generateSignature(QJsonObject data);
    QString buildBody(QList<QList<QString> > bodies, QString boundary);

private:
    QString API_URL         = "https://i.instagram.com/api/v1/";
    QString USER_AGENT      = "Instagram 9.2.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)";
    QString IG_SIG_KEY      = "012a54f51c49aa8c5c322416ab1410909add32c966bbaa0fe3dc58ac43fd7ede";
    QString SIG_KEY_VERSION = "4";

    QDir m_data_path;

    QNetworkAccessManager *m_manager;
    QNetworkReply *m_reply;
    QNetworkCookieJar *m_jar;

signals:
    void replySrtingReady(QVariant ans);

public slots:

private slots:
    void finishGetUrl();
    void saveCookie();
};

#endif // INSTAGRAMREQUEST_H
