#include "instagramrequest.h"
#include "instagram_p.h"
#include "../cripto/hmacsha.h"

#include <QDataStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkCookie>
#include <QNetworkCookieJar>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUuid>

InstagramRequest::InstagramRequest(QNetworkReply *reply,
                                       QObject *parent):
    QObject(parent),
    m_reply(reply)
{
    QObject::connect(reply, &QNetworkReply::finished, this, &InstagramRequest::finishGetUrl);
}


InstagramRequest *InstagramPrivate::fileRequest(QString endpoint, QString boundary, QByteArray data)
{
    QUrl url(Constants::apiUrl()+endpoint);
    QNetworkRequest request(url);

    request.setRawHeader("Connection","close");
    request.setRawHeader("Accept","*/*");
    request.setHeader(QNetworkRequest::ContentTypeHeader,"multipart/form-data; boundary="+boundary.toUtf8());
    request.setHeader(QNetworkRequest::ContentLengthHeader,data.size());
    request.setHeader(QNetworkRequest::UserAgentHeader,Constants::userAgent());

    request.setRawHeader("Cookie2","$Version=1");
    request.setRawHeader("Accept-Language","en-US");
    request.setRawHeader("Accept-Encoding","gzip");

    QNetworkReply *mReply = this->m_manager->post(request,data);

    return new InstagramRequest(mReply, this);
}

InstagramRequest *InstagramPrivate::request(QString endpoint, QByteArray post, bool apiV2, bool isGet)
{
    QString api_url = apiV2 ? Constants::apiUrl(true): Constants::apiUrl();

    QUrl url(api_url + endpoint);
    QNetworkRequest request(url);

    request.setRawHeader("Connection","close");
    request.setRawHeader("Accept","*/*");
    request.setRawHeader("Content-type","application/x-www-form-urlencoded; charset=UTF-8");
    request.setRawHeader("Cookie2","$Version=1");
    request.setRawHeader("Accept-Language","en-US");
    request.setRawHeader("User-Agent",Constants::userAgent());
    request.setRawHeader("X-IG-Capabilities", "3brTvw==");
    request.setRawHeader("X-IG-Connection-Type","WIFI");

    QNetworkReply *mReply;
    if (isGet) {
        mReply = this->m_manager->get(request);
    } else {
        mReply = this->m_manager->post(request, post);
    }

    return new InstagramRequest(mReply, this);
}

InstagramRequest *InstagramPrivate::timelineRequest(QString endpoint, QByteArray post, QString uuid, bool apiV2, bool isGet)
{
    QString api_url = apiV2 ? Constants::apiUrl(true): Constants::apiUrl();

    QUrl url(api_url + endpoint);
    QNetworkRequest request(url);

    QUuid a_uuid;
    QString a_uuid_id = a_uuid.createUuid().toString();

    request.setRawHeader("Connection","close");
    request.setRawHeader("Accept","*/*");
    request.setRawHeader("X-Ads-Opt-Out","0");
    request.setRawHeader("X-Google-AD-ID",a_uuid_id.toUtf8());
    request.setRawHeader("X-DEVICE-ID",uuid.toUtf8());
    request.setRawHeader("Content-type","application/x-www-form-urlencoded; charset=UTF-8");
    request.setRawHeader("Cookie2","$Version=1");
    request.setRawHeader("Accept-Language","en-US");
    request.setRawHeader("User-Agent",Constants::userAgent());
    request.setRawHeader("X-IG-Capabilities", "3brTvw==");
    request.setRawHeader("X-IG-Connection-Type","WIFI");

    QNetworkReply *mReply;
    if (isGet) {
        mReply = this->m_manager->get(request);
    } else {
        mReply = this->m_manager->post(request, post);
    }

    return new InstagramRequest(mReply, this);
}

InstagramRequest *InstagramPrivate::directRequest(QString endpoint, QString boundary, QByteArray data)
{
    QUrl url(Constants::apiUrl()+endpoint);
    QNetworkRequest request(url);

    request.setRawHeader("Connection","keep-alive");
    request.setRawHeader("Accept","*/*");
    request.setHeader(QNetworkRequest::ContentTypeHeader,"multipart/form-data; boundary="+boundary.toUtf8());
    request.setHeader(QNetworkRequest::ContentLengthHeader,data.size());
    request.setHeader(QNetworkRequest::UserAgentHeader,Constants::userAgent());

    request.setRawHeader("Accept-Language","en-en");

    QNetworkReply *mReply = this->m_manager->post(request,data);

    return new InstagramRequest(mReply, this);
}

void InstagramRequest::finishGetUrl()
{
    //this->m_reply->deleteLater();
    QNetworkReply *nReply = qobject_cast<QNetworkReply *>(sender());
    QVariant answer = QString::fromUtf8(nReply->readAll());
    if(answer.toString().length() > 1)
    {
        Q_EMIT replyStringReady(answer);
    }
    nReply->deleteLater();
}

void InstagramPrivate::saveCookie() const
{
    QList<QNetworkCookie> list =
        m_manager->cookieJar()->cookiesForUrl(QUrl(Constants::apiUrl()+"/"));

    QFile f(m_data_path.absolutePath()+"/cookies.dat");
    f.open(QIODevice::ReadWrite);
    for(int i = 0; i < list.size(); ++i){
        QDataStream s(&f);
        s << list.at(i).toRawForm();
    }

    f.close();
}


QString InstagramRequest::generateSignature(QJsonObject data)
{
    QJsonDocument data_doc(data);
    QString data_string(data_doc.toJson(QJsonDocument::Compact));

    //Fix to image config string
    data_string.replace("\"crop_center\":[0,0]","\"crop_center\":[0.0,-0.0]");

    HmacSHA *hmac = new HmacSHA();
    QByteArray hash = hmac->hash(data_string.toUtf8(), Constants::isSigKey());

    return QString("ig_sig_key_version="+Constants::sigKeyVersion()+"&signed_body="+hash.toHex()+"."+data_string.toUtf8());
}


