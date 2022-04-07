#ifndef INSTAGRAM_P_H
#define INSTAGRAM_P_H

#include "instagram.h"
#include "instagramrequest.h"

#include <QDir>
#include <QObject>
#include <QString>

class QNetworkCookieJar;

class InstagramPrivate: public QObject
{
    Q_OBJECT
    Q_DECLARE_PUBLIC(Instagram)

public:
    InstagramPrivate(Instagram *q);

    void setNetworkAccessManager(QNetworkAccessManager *nam);
    void loadCookies();

    InstagramRequest *fileRequest(QString endpoint, QByteArray data, QString upload_id);
    InstagramRequest *request(QString endpoint, QByteArray post, bool apiV2 = false, bool isGet = false);
    InstagramRequest *timelineRequest(QString endpoint, QByteArray post, QString uuid, bool apiV2 = false, bool isGet = false);
    InstagramRequest *directRequest(QString endpoint, QString boundary, QByteArray data);

private Q_SLOTS:
    void setUser(bool force = true);
    void doLogin();
    void syncFeatures();
    void profileConnect(QVariant profile);
    void configurePhoto(QVariant answer);
    void saveCookie() const;

private:
    QString m_username;
    QString m_password;
    QString m_userID;
    QString m_debug;
    QString m_username_id;
    QString m_uuid;
    QString m_device_id;
    QString m_token;
    QString m_csrftoken=m_token;
    QString m_rank_token;
    QString m_IGDataPath;
    QString m_profile_pic;
    QString m_caption;
    QString m_image_path;

    QDir m_data_path;
    QDir m_photos_path;

    QVariantMap lastUploadLocation;

    QNetworkAccessManager *m_manager;
    QNetworkCookieJar *m_jar;

    bool m_isLoggedIn = false;

    QString generateDeviceId();

    Instagram *q_ptr;
};

#endif // INSTAGRAM_P_H
