#include "instagram_p.h"
#include "constants.h"

#include <QCryptographicHash>
#include <QFileInfo>
#include <QNetworkAccessManager>
#include <QNetworkCookie>
#include <QNetworkCookieJar>
#include <QStandardPaths>
#include <QDateTime>
#include <QUuid>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QImage>
#include <QDataStream>
#include <QDebug>

InstagramPrivate::InstagramPrivate(Instagram *q):
    m_manager(0),
    q_ptr(q)
{
    m_data_path = QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));

    if(!m_data_path.exists())
    {
        m_data_path.mkpath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    }

    m_jar = new QNetworkCookieJar;
    loadCookies();

    setNetworkAccessManager(new QNetworkAccessManager());

    QUuid uuid;
    m_uuid = uuid.createUuid().toString();

    m_device_id = generateDeviceId();
    setUser();
}

void InstagramPrivate::setNetworkAccessManager(QNetworkAccessManager *nam)
{
    if (nam == m_manager) return;

    if (m_manager) {
        delete m_manager;
    }
    m_manager = nam;
    if (m_manager) {
        QObject::connect(m_manager, &QNetworkAccessManager::finished,
                         this, &InstagramPrivate::saveCookie);

        m_manager->setCookieJar(m_jar);
        m_jar->setParent(this);
    }
}

void InstagramPrivate::loadCookies()
{
    QFile f(m_data_path.absolutePath()+"/cookies.dat");
    f.open(QIODevice::ReadOnly);
    QDataStream s(&f);

    while(!s.atEnd()){
        QByteArray c;
        s >> c;
        QList<QNetworkCookie> list = QNetworkCookie::parseCookies(c);
        if(list.count() > 0)
        {
            this->m_jar->insertCookie(list.at(0));
        }
    }
}

QString InstagramPrivate::generateDeviceId()
{
    QFileInfo fi(m_data_path.absolutePath());
    QByteArray volatile_seed = QString::number(fi.created().toMSecsSinceEpoch()).toUtf8();

    QByteArray data_1 = QCryptographicHash::hash(
                        QString(m_username+m_password).toUtf8(),
                        QCryptographicHash::Md5).toHex();

    QString data_2 = QString(QCryptographicHash::hash(
                QString(data_1+volatile_seed).toUtf8(),
                QCryptographicHash::Md5).toHex());

    QString data = "android-"+data_2.left(16);

    return data;
}

void InstagramPrivate::setUser(bool force)
{
    Q_Q(Instagram);

    if(m_username.length() == 0 || m_password.length() == 0)
    {
        Q_EMIT q->error("Username and/or password is clean");
    }
    else
    {
        QFile f_cookie(m_data_path.absolutePath()+"/cookies.dat");
        QFile f_userId(m_data_path.absolutePath()+"/userId.dat");
        QFile f_token(m_data_path.absolutePath()+"/token.dat");

        if(f_cookie.exists() && f_userId.exists() && f_token.exists())
        {
            f_userId.open(QFile::ReadOnly);
            QTextStream f_userId_d(&f_userId);

            f_token.open(QFile::ReadOnly);
            QTextStream f_token_d(&f_token);

            m_isLoggedIn = true;
            m_username_id = f_userId_d.readAll().trimmed();
            m_rank_token = m_username_id+"_"+m_uuid;
            m_token = f_token_d.readAll().trimmed();

            if (!force) {
                QVariant a;
                Q_EMIT q->profileConnected(a);
            }
        } else {
            if (!force) {
                Q_EMIT q->profileConnectedFail();
                doLogin();
            }
        }
    }
}

Instagram::Instagram(QObject *parent):
    QObject(parent),
    m_busy(false),
    d_ptr(new InstagramPrivate(this))
{
}

Instagram::~Instagram()
{
}

bool Instagram::busy() const
{
    return m_busy;
}

void Instagram::login(bool force, QString username, QString password, bool set)
{
    Q_D(Instagram);

    if (set == true) {
        d->m_username = username;
        d->m_password = password;
    }

    if (force == false) {
        d->setUser(false);
    } else if(!d->m_isLoggedIn || force) {
        d->setUser(true);

        InstagramRequest *loginRequest =
            d->request("si/fetch_headers/?challenge_type=signup&guid="+d->m_uuid,NULL);
        QObject::connect(loginRequest, &InstagramRequest::replyStringReady, d, &InstagramPrivate::doLogin);
    }
}

void Instagram::logout()
{
    Q_D(Instagram);

    QFile f_cookie(d->m_data_path.absolutePath()+"/cookies.dat");
    QFile f_userId(d->m_data_path.absolutePath()+"/userId.dat");
    QFile f_token(d->m_data_path.absolutePath()+"/token.dat");

    f_cookie.remove();
    f_userId.remove();
    f_token.remove();

    InstagramRequest *logoutRequest = d->request("accounts/logout/"
                                                  "?_csrftoken=" + d->m_csrftoken +
                                                  "&guid=" + d->m_uuid +
                                                  "&device_id=" + d->m_device_id +
                                                  "&_uuid" + d->m_uuid
                                                  , NULL);

    QObject::connect(logoutRequest, &InstagramRequest::replyStringReady, this, &Instagram::doLogout);
}

void Instagram::setUsername(QString username)
{
    Q_D(Instagram);
    d->m_username = username;
}

void Instagram::setPassword(QString password)
{
    Q_D(Instagram);
    d->m_password = password;
}

QString Instagram::getUsernameId()
{
    Q_D(Instagram);
    return d->m_username_id;
}

void InstagramPrivate::doLogin()
{
    Q_Q(Instagram);

    QRegExp rx("token=(\\w+);");
    QFile f(m_data_path.absolutePath()+"/cookies.dat");
    if (!f.open(QFile::ReadOnly))
    {
        Q_EMIT q->error("Can`t open token file");
    }
    QTextStream in(&f);
    rx.indexIn(in.readAll());
    if(rx.cap(1).length() > 0)
    {
        m_token = rx.cap(1);
    }
    else
    {
        Q_EMIT q->error("Can`t find token");
    }
    QUuid uuid;

    QJsonObject data;
        data.insert("phone_id",     uuid.createUuid().toString());
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+m_token);
        data.insert("username",     m_username);
        data.insert("guid",         m_uuid);
        data.insert("device_id",    m_device_id);
        data.insert("password",     m_password);
        data.insert("login_attempt_count", QString("0"));

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *request =
        this->request("accounts/login/",signature.toUtf8());

    QObject::connect(request,&InstagramRequest::replyStringReady,this,&InstagramPrivate::profileConnect);
}

void Instagram::confirm2Factor(QString code, QString identifier, QString method)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("trust_this_device",        "true");
        data.insert("verification_method",      method);
        data.insert("verification_code",        code);
        data.insert("two_factor_identifier",    identifier);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("username",     d->m_username);
        data.insert("password",     d->m_password);
        data.insert("guid",         d->m_uuid);
        data.insert("device_id",    d->m_device_id);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *confirm2FactorRequest =
            d->request("accounts/two_factor_login/",signature.toUtf8());

    QObject::connect(confirm2FactorRequest, &InstagramRequest::replyStringReady, d, &InstagramPrivate::profileConnect);
}

void InstagramPrivate::profileConnect(QVariant profile)
{
    Q_Q(Instagram);
    QJsonDocument profile_doc = QJsonDocument::fromJson(profile.toString().toUtf8());
    QJsonObject profile_obj = profile_doc.object();
    if(profile_obj["status"].toString().toUtf8() == "fail")
    {
        if (profile_obj.contains("two_factor_required") && profile_obj["two_factor_required"] == true) {
            Q_EMIT q->twoFactorRequired(profile_obj);
        } else {
            Q_EMIT q->error(profile_obj["message"].toString().toUtf8());
            Q_EMIT q->profileConnectedFail();

            // Challenge Required
            if (profile_obj["message"].toString().toUtf8() == "challenge_required") {
                QJsonObject challenge_obj = profile_obj["challenge"].toObject();
                Q_EMIT q->challengeRequired(challenge_obj);
            }
        }
    }
    else
    {
        QJsonObject user = profile_obj["logged_in_user"].toObject();
        m_isLoggedIn = true;
        m_username_id = QString("%1").arg(user["pk"].toDouble(),0,'f',0);

        m_rank_token = m_username_id+"_"+m_uuid;

        // save username_id
        QFile fu(m_data_path.absolutePath()+"/userId.dat");
        fu.open(QIODevice::ReadWrite);
        QTextStream su(&fu);
        su << m_username_id << endl;
        fu.close();

        // save token
        QFile ft(m_data_path.absolutePath()+"/token.dat");
        ft.open(QIODevice::ReadWrite);
        QTextStream st(&ft);
        st << m_token << endl;
        ft.close();

        syncFeatures();

        Q_EMIT q->profileConnected(profile);
    }
}

void InstagramPrivate::syncFeatures()
{
    QJsonObject data;
        data.insert("_uuid",        m_uuid);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+m_token);
        data.insert("_uid",         m_username_id);
        data.insert("id",           m_username_id);
        data.insert("password",     m_password);
        data.insert("experiments",  Constants::experiments());

    QString signature = InstagramRequest::generateSignature(data);
    request("qe/sync/",signature.toUtf8());
}

//FIXME: uploadImage is not public yeat. Give me few weeks to optimize code
void Instagram::postImage(QString path, QString caption, QString upload_id)
{
    Q_D(Instagram);

    d->m_caption = caption;
    d->m_image_path = path;

    QFile image(path);
    if(!image.open(QIODevice::ReadOnly))
    {
        Q_EMIT error("Image not found");
    }

    QByteArray dataStream = image.readAll();

    QFileInfo info(image.fileName());
    QString ext = info.completeSuffix();

    QString boundary = d->m_uuid;

    if(upload_id.size() == 0)
    {
        upload_id =QString::number(QDateTime::currentMSecsSinceEpoch());
    }
    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"upload_id\"\r\n\r\n";
    body += upload_id+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"_uuid\"\r\n\r\n";
    body += d->m_uuid.replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n";
    body += d->m_token+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"image_compression\"\r\n\r\n";
    body += "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"70\"}\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"photo\"; filename=\"pending_media_"+upload_id+"."+ext+"\"\r\n";
    body += "Content-Transfer-Encoding: binary\r\n";
    body += "Content-Type: application/octet-stream\r\n\r\n";

    body += dataStream+"\r\n";
    body += "--"+boundary+"--";

    InstagramRequest *putPhotoReqest =
        d->fileRequest("upload/photo/",boundary, body);

    QObject::connect(putPhotoReqest,&InstagramRequest::replyStringReady,d,&InstagramPrivate::configurePhoto);
}

void InstagramPrivate::configurePhoto(QVariant answer)
{
    Q_Q(Instagram);
    QJsonDocument jsonResponse = QJsonDocument::fromJson(answer.toByteArray());
    QJsonObject jsonObject = jsonResponse.object();
    if(jsonObject["status"].toString() != QString("ok"))
    {
        Q_EMIT q->error(jsonObject["message"].toString());
    }
    else
    {
        QString upload_id = jsonObject["upload_id"].toString();
        if(upload_id.length() == 0)
        {
            Q_EMIT q->error("Wrong UPLOAD_ID:"+upload_id);
        }
        else
        {
            QImage image = QImage(m_image_path);

            QJsonObject device;
                device.insert("manufacturer",   QString("Xiaomi"));
                device.insert("model",          QString("HM 1SW"));
                device.insert("android_version",18);
                device.insert("android_release",QString("4.3"));
            QJsonObject extra;
                extra.insert("source_width",    image.width());
                extra.insert("source_height",   image.height());

            QJsonArray crop_original_size;
                crop_original_size.append(image.width());
                crop_original_size.append(image.height());
            QJsonArray crop_center;
                crop_center.append(0.0);
                crop_center.append(-0.0);

            QJsonObject edits;
                edits.insert("crop_original_size", crop_original_size);
                edits.insert("crop_zoom",          1.3333334);
                edits.insert("crop_center",        crop_center);

            QJsonObject data;
                data.insert("upload_id",            upload_id);
                data.insert("camera_model",         QString("HM1S"));
                data.insert("source_type",          3);
                data.insert("date_time_original",   QDateTime::currentDateTime().toString("yyyy:MM:dd HH:mm:ss"));
                data.insert("camera_make",          QString("XIAOMI"));
                data.insert("edits",                edits);
                data.insert("extra",                extra);
                data.insert("device",               device);
                data.insert("caption",              m_caption);
                data.insert("_uuid",                m_uuid);
                data.insert("_uid",                 m_username_id);
                data.insert("_csrftoken",           "Set-Cookie: csrftoken="+m_token);

            QString signature = InstagramRequest::generateSignature(data);
            InstagramRequest *configureImageRequest =
                request("media/configure/",signature.toUtf8());
            QObject::connect(configureImageRequest,&InstagramRequest::replyStringReady,q,&Instagram::imageConfigureDataReady);
        }
    }
    m_caption = "";
    m_image_path = "";
}

//FIXME: uploadImage is not public yeat. Give me few weeks to optimize code
void Instagram::postVideo(QFile *video)
{

}

void Instagram::getPopularFeed(QString max_id)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    QString target ="feed/popular/?people_teaser_supported=1&rank_token="+d->m_rank_token+"&ranked_content=true&";
    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getPopularFeedRequest =
        d->request(target,NULL);
    QObject::connect(getPopularFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(popularFeedDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();

}

void Instagram::searchUsername(QString username)
{
    Q_D(Instagram);

    InstagramRequest *searchUsernameRequest =
        d->request("users/"+username+"/usernameinfo/", NULL);
    QObject::connect(searchUsernameRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(searchUsernameDataReady(QVariant)));
}

void Instagram::rotateImg(QString filename, qreal deg)
{
    QImage image(filename);
    QTransform rot;
    rot.rotate(deg);
    image = image.transformed(rot);

    QFile imgFile(filename);
    imgFile.open(QIODevice::ReadWrite);

    if(!image.save(&imgFile,"JPG",100))
    {
        qDebug() << "NOT SAVE";
    }

    imgFile.close();
}

void Instagram::cropImg(QString filename, bool squared, bool isRotated)
{

    QImage image(filename);
    if(!isRotated) {
        QTransform rot;
        rot.rotate(90);
        image = image.transformed(rot);
    }

    int min_size = qMin(image.width(),image.height());
    int max_size = qMax(image.width(),image.height());

    if(squared)
    {
        if(isRotated) {
            image = image.copy(max_size / 4, 0, min_size, min_size);
        } else
            image = image.copy(0,(max_size-min_size) / 2, min_size, min_size);
    }
    else
    {
        if(isRotated) {
            int size54 = max_size * (5.0/4.0);
            image = image.copy(0, max_size / 4, size54,min_size);
        }
        else {
            int size54 = min_size * 5/4;
            image = image.copy(0,(max_size-size54)/2,min_size,size54);
        }
    }

    QFile imgFile(filename);
    imgFile.open(QIODevice::ReadWrite);

    if(!image.save(&imgFile,"JPG",100))
    {
        qDebug() << "NOT SAVE";
    }

    imgFile.close();
}

void Instagram::cropImg(QString in_filename, QString out_filename, int topSpace, bool squared)
{
    QImage image(in_filename);
    int min_size = qMin(image.width(),image.height());

    if(squared)
    {
        image = image.copy(0,topSpace,min_size,min_size);
    }
    else
    {
        int size54 = min_size*5/4;
        image = image.copy(0,topSpace,min_size,size54);
    }

    if(!image.save(out_filename))
    {
        qDebug() << "NOT SAVE HERE";
    }
}

void Instagram::scaleImg(QString filename)
{
    QImage image(filename);

    QFile imgFile(filename);
    imgFile.open(QIODevice::ReadWrite);

    if (image.width() > 800) {
        int w_s = image.width()/800;

        int s_w = image.width()/w_s;
        int s_h = image.height()/w_s;

        image = image.scaled(s_w, s_h, Qt::KeepAspectRatio);

        if(!image.save(&imgFile,"JPG",100))
        {
            qDebug() << "NOT SAVE ON CROP";
        } else {
            //emit imgScaled();
        }
    } else {
        //emit imgScaled();
    }

    imgFile.close();
}

void Instagram::setNetworkAccessManager(QNetworkAccessManager *nam)
{
    Q_D(Instagram);
    d->setNetworkAccessManager(nam);
}

QNetworkAccessManager *Instagram::networkAccessManager() const
{
    Q_D(const Instagram);
    return d->m_manager;
}


void Instagram::setProfilePic(QString userpic){

    Q_D(Instagram);
    if (d->m_profile_pic == "") {
        d->m_profile_pic = userpic;
    }
}

QString Instagram::getProfilePic(){

    Q_D(const Instagram);
    if (d->m_profile_pic != "") {
        return d->m_profile_pic;
    }
    else return "";
}
