#include <src/instagram.h>
#include <src/instagramrequest.h>

#include <QCryptographicHash>

#include <QFileInfo>
#include <QStandardPaths>
#include <QDateTime>
#include <QUuid>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QImage>
#include <QDataStream>
#include <QUrl>

#include <QDebug>

Instagram::Instagram(QObject *parent)
    : QObject(parent),
      m_busy(false)
{
    this->m_data_path =  QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    this->m_photos_path = QDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));

    if(!m_data_path.exists())
    {
        m_data_path.mkpath(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    }

    if(!m_photos_path.exists())
    {
        m_photos_path.mkpath(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));
    }

    QUuid uuid;
    this->m_uuid = uuid.createUuid().toString();

    this->m_device_id = this->generateDeviceId();

    this->setUser();
}

bool Instagram::busy() const
{
    return m_busy;
}

QString Instagram::error() const
{
    return m_error;
}

QString Instagram::photos_path() const
{
    return m_photos_path.absolutePath();
}

QString Instagram::generateDeviceId()
{
    QFileInfo fi(m_data_path.absolutePath());
    QByteArray volatile_seed = QString::number(fi.created().toMSecsSinceEpoch()).toUtf8();

    QByteArray data_1 = QCryptographicHash::hash(
                        QString(this->m_username+this->m_password).toUtf8(),
                        QCryptographicHash::Md5).toHex();

    QString data_2 = QString(QCryptographicHash::hash(
                QString(data_1+volatile_seed).toUtf8(),
                QCryptographicHash::Md5).toHex());

    QString data = "android-"+data_2.left(16);

    return data;
}


void Instagram::setUser()
{
    if(this->m_username.length() == 0 or this->m_password.length() == 0)
    {
        emit error("Username anr/or password is clean");
    }
    else
    {
        QFile f_cookie(m_data_path.absolutePath()+"/cookies.dat");
        QFile f_userId(m_data_path.absolutePath()+"/userId.dat");
        QFile f_token(m_data_path.absolutePath()+"/token.dat");

        if(f_cookie.exists() && f_userId.exists() && f_token.exists())
        {
            this->m_isLoggedIn = true;
            this->m_username_id = f_userId.readAll().trimmed();
            this->m_rank_token = this->m_username_id+"_"+this->m_uuid;
            this->m_token = f_token.readAll().trimmed();

            this->doLogin();
        }
    }
}

void Instagram::login(bool forse)
{
    if(!this->m_isLoggedIn or forse)
    {
        this->setUser();

        Instagram::syncFeatures(true);

        InstagramRequest *loginRequest = new InstagramRequest();
        loginRequest->request("si/fetch_headers/?challenge_type=signup&guid="+this->m_uuid,NULL);
        QObject::connect(loginRequest,SIGNAL(replySrtingReady(QVariant)),this,SLOT(doLogin()));
    }
}

void Instagram::logout()
{
    QFile f_cookie(m_data_path.absolutePath()+"/cookies.dat");
    QFile f_userId(m_data_path.absolutePath()+"/userId.dat");
    QFile f_token(m_data_path.absolutePath()+"/token.dat");

    f_cookie.remove();
    f_userId.remove();
    f_token.remove();

    InstagramRequest *looutRequest = new InstagramRequest();
    looutRequest->request("accounts/logout/",NULL);
    QObject::connect(looutRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(doLogout(QVariant)));
}

void Instagram::doLogin()
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *request = new InstagramRequest();
    QRegExp rx("token=(\\w+);");
    QFile f(m_data_path.absolutePath()+"/cookies.dat");
    if (!f.open(QFile::ReadOnly))
    {
        //qDebug() << m_data_path.absolutePath()+"/cookies.dat";
        qDebug() << f.errorString();
        emit error("Can`t open token file");
    }
    QTextStream in(&f);
    rx.indexIn(in.readAll());
    if(rx.cap(1).length() > 0)
    {
        this->m_token = rx.cap(1);
        //qDebug() << rx.cap(1);
    }
    else
    {
        emit error("Can`t find token");
    }
    QUuid uuid;

    QJsonObject data;
        data.insert("phone_id",     uuid.createUuid().toString());
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("username",     this->m_username);
        data.insert("guid",         this->m_uuid);
        data.insert("device_id",    this->m_device_id);
        data.insert("password",     this->m_password);
        data.insert("login_attempt_count", QString("0"));

    QString signature = request->generateSignature(data);
    request->request("accounts/login/",signature.toUtf8());

    QObject::connect(request,SIGNAL(replySrtingReady(QVariant)),this,SLOT(profileConnect(QVariant)));
}

void Instagram::profileConnect(QVariant profile)
{
    QJsonDocument profile_doc = QJsonDocument::fromJson(profile.toString().toUtf8());
    QJsonObject profile_obj = profile_doc.object();

    //qDebug() << "Reply: " << profile_obj;

    if(profile_obj["status"].toString().toUtf8() == "fail")
    {
        emit error(profile_obj["message"].toString().toUtf8());
        emit profileConnectedFail();
    }
    else
    {

        QJsonObject user = profile_obj["logged_in_user"].toObject();

        this->m_isLoggedIn = true;
        this->m_username_id = QString::number(user["pk"].toDouble(),'g', 10);
        this->m_rank_token = this->m_username_id+"_"+this->m_uuid;

        this->syncFeatures();
        this->autoCompleteUserList();

        emit profileConnected(profile);
    }

    m_busy = false;
    emit busyChanged();
}

void Instagram::syncFeatures(bool prelogin)
{
    if (prelogin) {
        InstagramRequest *syncRequest = new InstagramRequest();
        QJsonObject data;;
            data.insert("id",           this->m_uuid);
            data.insert("experiments",  LOGIN_EXPERIMENTS);

        QString signature = syncRequest->generateSignature(data);
        syncRequest->request("qe/sync/",signature.toUtf8());
    } else {
        InstagramRequest *syncRequest = new InstagramRequest();
        QJsonObject data;
            data.insert("_uuid",        this->m_uuid);
            data.insert("_uid",         this->m_username_id);
            data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
            data.insert("id",           this->m_username_id);
            data.insert("experiments",  EXPERIMENTS);

        QString signature = syncRequest->generateSignature(data);
        syncRequest->request("qe/sync/",signature.toUtf8());
    }
}

void Instagram::autoCompleteUserList()
{
    InstagramRequest *autoCompleteUserListRequest = new InstagramRequest();
    autoCompleteUserListRequest->request("friendships/autocomplete_user_list/?version=2",NULL);
    QObject::connect(autoCompleteUserListRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(autoCompleteUserListReady(QVariant)));
}

void Instagram::postImage(QString path, QString caption, QVariantMap location, QString upload_id)
{
    m_busy = true;
    emit busyChanged();

    lastUploadLocation = location;

    this->m_caption = caption;
    this->m_image_path = path;

    QFile image(path);
    image.open(QIODevice::ReadOnly);
    QByteArray dataStream = image.readAll();

    QFileInfo info(image.fileName());
    QString ext = info.completeSuffix();

    QString boundary = this->m_uuid;

    if(upload_id.size() == 0)
    {
        upload_id = QString::number(QDateTime::currentMSecsSinceEpoch());
    }
    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"upload_id\"\r\n\r\n";
    body += upload_id+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"_uuid\"\r\n\r\n";
    body += this->m_uuid.replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"_csrftoken\"\r\n\r\n";
    body += this->m_token+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"image_compression\"\r\n\r\n";
    body += "{\"lib_name\":\"jt\",\"lib_version\":\"1.3.0\",\"quality\":\"87\"}\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"photo\"; filename=\"pending_media_"+upload_id+"."+ext+"\"\r\n";
    body += "Content-Transfer-Encoding: binary\r\n";
    body += "Content-Type: application/octet-stream\r\n\r\n";

    body += dataStream+"\r\n";
    body += "--"+boundary+"--";

    InstagramRequest *putPhotoReqest = new InstagramRequest();
    putPhotoReqest->fileRquest("upload/photo/",boundary, body);

    QObject::connect(putPhotoReqest,SIGNAL(progressReady(double)),this,SIGNAL(imageUploadProgressDataReady(double)));
    QObject::connect(putPhotoReqest,SIGNAL(replySrtingReady(QVariant)),this,SLOT(configurePhoto(QVariant)));
}

void Instagram::configurePhoto(QVariant answer)
{
    QJsonDocument jsonResponse = QJsonDocument::fromJson(answer.toByteArray());
    QJsonObject jsonObject = jsonResponse.object();
    if(jsonObject["status"].toString() != QString("ok"))
    {
        emit error(jsonObject["message"].toString());
    }
    else
    {
        QString upload_id = jsonObject["upload_id"].toString();
        if(upload_id.length() == 0)
        {
            emit error("Wrong UPLOAD_ID:"+upload_id);
        }
        else
        {
            QImage image = QImage(this->m_image_path);
            InstagramRequest *configureImageRequest = new InstagramRequest();

            //qDebug() << "width: " << image.width();
            //qDebug() << "height: " << image.height();

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
                edits.insert("crop_zoom",          1);
                edits.insert("crop_center",        crop_center);

            QJsonObject data;
                data.insert("_csrftoken",           "Set-Cookie: csrftoken="+this->m_token);
                data.insert("media_folder",         "Instagram");
                data.insert("source_type",          4);
                data.insert("_uid",                 this->m_username_id);
                data.insert("_uuid",                this->m_uuid);
                data.insert("caption",              this->m_caption);
                data.insert("upload_id",            upload_id);
                data.insert("device",               device);
                data.insert("edits",                edits);
                data.insert("extra",                extra);

                if (lastUploadLocation.count() > 0 && lastUploadLocation["name"].toString().length() > 0) {
                    QJsonObject location;
                    QString eisk = lastUploadLocation["external_id_source"].toString() + "_id";
                    location.insert(eisk, lastUploadLocation["external_id"].toString());
                    location.insert("name",             lastUploadLocation["name"].toString());
                    location.insert("lat",              lastUploadLocation["lat"].toString());
                    location.insert("lng",              lastUploadLocation["lng"].toString());
                    location.insert("address",          lastUploadLocation["address"].toString());
                    location.insert("external_source",  lastUploadLocation["external_id_source"].toString());

                    QJsonDocument doc(location);
                    QString strJson(doc.toJson(QJsonDocument::Compact));

                    data.insert("location",             strJson);
                    data.insert("geotag_enabled",       true);
                    data.insert("media_latitude",       lastUploadLocation["lat"].toString());
                    data.insert("posting_latitude",     lastUploadLocation["lat"].toString());
                    data.insert("media_longitude",      lastUploadLocation["lng"].toString());
                    data.insert("posting_longitude",    lastUploadLocation["lng"].toString());
                    data.insert("altitude",             rand() % 10 + 800);
                }


            QString signature = configureImageRequest->generateSignature(data);
            configureImageRequest->request("media/configure/",signature.toUtf8());
            QObject::connect(configureImageRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(imageConfigureDataReady(QVariant)));

            lastUploadLocation.clear();

            m_busy = false;
            emit busyChanged();
        }
    }
    this->m_caption = "";
    this->m_image_path = "";
}

//FIXME: uploadImage is not public yeat. Give me few weeks to optimize code
void Instagram::postVideo(QFile *video)
{

}

void Instagram::editMedia(QString mediaId, QString captionText)
{
    InstagramRequest *editMediaRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("caption_text", captionText);

    QString signature = editMediaRequest->generateSignature(data);
    editMediaRequest->request("media/"+mediaId+"/edit_media/",signature.toUtf8());
    QObject::connect(editMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaEdited(QVariant)));
}

void Instagram::infoMedia(QString mediaId)
{
    InstagramRequest *infoMediaRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id", mediaId);

    QString signature = infoMediaRequest->generateSignature(data);
    infoMediaRequest->request("media/"+mediaId+"/info/",signature.toUtf8());
    QObject::connect(infoMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaInfoReady(QVariant)));
}

void Instagram::deleteMedia(QString mediaId)
{
    InstagramRequest *deleteMediaRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",    mediaId);

    QString signature = deleteMediaRequest->generateSignature(data);
    deleteMediaRequest->request("media/"+mediaId+"/delete/",signature.toUtf8());
    QObject::connect(deleteMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaDeleted(QVariant)));
}

void Instagram::removeSelftag(QString mediaId)
{
    InstagramRequest *removeSelftagRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = removeSelftagRequest->generateSignature(data);
    removeSelftagRequest->request("usertags/"+mediaId+"/remove/",signature.toUtf8());
    QObject::connect(removeSelftagRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(removeSelftagDone(QVariant)));
}

void Instagram::postComment(QString mediaId, QString commentText)
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *postCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("comment_text", commentText);

    QString signature = postCommentRequest->generateSignature(data);
    postCommentRequest->request("media/"+mediaId+"/comment/",signature.toUtf8());
    QObject::connect(postCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentPosted(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::deleteComment(QString mediaId, QString commentId)
{
    InstagramRequest *deleteCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = deleteCommentRequest->generateSignature(data);
    deleteCommentRequest->request("media/"+mediaId+"/comment/"+commentId+"/delete/",signature.toUtf8());
    QObject::connect(deleteCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentDeleted(QVariant)));
}

void Instagram::likeComment(QString commentId)
{
    InstagramRequest *likeCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = likeCommentRequest->generateSignature(data);
    likeCommentRequest->request("media/"+commentId+"/comment_like/",signature.toUtf8());
    QObject::connect(likeCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentLiked(QVariant)));
}

void Instagram::unLikeComment(QString commentId)
{
    InstagramRequest *unLikeCommentRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = unLikeCommentRequest->generateSignature(data);
    unLikeCommentRequest->request("media/"+commentId+"/comment_unlike/",signature.toUtf8());
    QObject::connect(unLikeCommentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(commentUnLiked(QVariant)));
}

//FIXME changeProfilePicture is not public yeat. Give me few weeks to optimize code
void Instagram::changeProfilePicture(QFile *photo)
{

}

void Instagram::removeProfilePicture()
{
    InstagramRequest *removeProfilePictureRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = removeProfilePictureRequest->generateSignature(data);
    removeProfilePictureRequest->request("maccounts/remove_profile_picture/",signature.toUtf8());
    QObject::connect(removeProfilePictureRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(profilePictureDeleted(QVariant)));
}

void Instagram::setPrivateAccount()
{
    InstagramRequest *setPrivateRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = setPrivateRequest->generateSignature(data);
    setPrivateRequest->request("accounts/set_private/",signature.toUtf8());
    QObject::connect(setPrivateRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(setProfilePrivate(QVariant)));
}

void Instagram::setPublicAccount()
{
    InstagramRequest *setPublicRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = setPublicRequest->generateSignature(data);
    setPublicRequest->request("accounts/set_public/",signature.toUtf8());
    QObject::connect(setPublicRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(setProfilePublic(QVariant)));
}

void Instagram::getProfileData()
{
    InstagramRequest *getProfileRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);

    QString signature = getProfileRequest->generateSignature(data);
    getProfileRequest->request("accounts/current_user/?edit=true",signature.toUtf8());
    QObject::connect(getProfileRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(profileDataReady(QVariant)));
}
/**
 * Edit profile.
 *
 * @param QString url
 *   Url - website. "" for nothing
 * @param QString phone
 *   Phone number. "" for nothing
 * @param QString first_name
 *   Name. "" for nothing
 * @param QString email
 *   Email. Required.
 * @param bool gender
 *   Gender. male = true , female = false
 */
void Instagram::editProfile(QString url, QString phone, QString first_name, QString biography, QString email, bool gender)
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *editProfileRequest = new InstagramRequest();
    QString gen_string;
    if(gender)
    {
        gen_string = "1";
    }
    else
    {
        gen_string = "0";
    }

    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("external_url", url);
        data.insert("phone_number", phone);
        data.insert("username",     this->m_username);
        data.insert("first_name",    first_name);
        data.insert("biography",    biography);
        data.insert("email",        email);
        data.insert("gender",       gen_string);

    QString signature = editProfileRequest->generateSignature(data);
    editProfileRequest->request("accounts/edit_profile/",signature.toUtf8());
    QObject::connect(editProfileRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(editDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getUsernameInfo(QString usernameId)
{
    InstagramRequest *getUsernameRequest = new InstagramRequest();
    getUsernameRequest->request("users/"+usernameId+"/info/",NULL);
    QObject::connect(getUsernameRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(usernameDataReady(QVariant)));
}

void Instagram::getRecentActivity()
{
    InstagramRequest *getRecentActivityRequest = new InstagramRequest();
    getRecentActivityRequest->request("news/inbox/?",NULL);
    QObject::connect(getRecentActivityRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(recentActivityDataReady(QVariant)));
}

void Instagram::getFollowingRecentActivity()
{
    InstagramRequest *getFollowingRecentRequest = new InstagramRequest();
    getFollowingRecentRequest->request("news/?",NULL);
    QObject::connect(getFollowingRecentRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(followingRecentDataReady(QVariant)));
}

void Instagram::getUserTags(QString usernameId)
{
    InstagramRequest *getUserTagsRequest = new InstagramRequest();
    getUserTagsRequest->request("usertags/"+usernameId+"/feed/?rank_token="+this->m_rank_token+"&ranked_content=true&",NULL);
    QObject::connect(getUserTagsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userTagsDataReady(QVariant)));
}

void Instagram::getGeoMedia(QString usernameId)
{
    InstagramRequest *getGeoMediaRequest = new InstagramRequest();
    getGeoMediaRequest->request("maps/user/"+usernameId+"/",NULL);
    QObject::connect(getGeoMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(geoMediaDataReady(QVariant)));
}

void Instagram::tagFeed(QString tag, QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="feed/tag/"+tag+"/?rank_token="+this->m_rank_token+"&ranked_content=true&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getTagFeedRequest = new InstagramRequest();
    getTagFeedRequest->request(target,NULL);
    QObject::connect(getTagFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(tagFeedDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getTimeLine(QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="feed/timeline/?rank_token="+this->m_rank_token+"&ranked_content=true&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getTimeLineRequest = new InstagramRequest();
    getTimeLineRequest->request(target,NULL);
    QObject::connect(getTimeLineRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(timeLineDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getUsernameFeed(QString usernameID, QString maxid, QString minTimestamp)
{
    QString endpoint;
    endpoint = "feed/user/"+usernameID+"/?rank_token="+this->m_rank_token;
    if(maxid.length() > 0)
    {
        endpoint += "&max_id="+maxid;
    }
    if(minTimestamp.length() > 0)
    {
        endpoint += "&min_timestamp="+minTimestamp;
    }
    endpoint += "&ranked_content=true";

    InstagramRequest *getUserTimeLineRequest = new InstagramRequest();
    getUserTimeLineRequest->request(endpoint,NULL);
    QObject::connect(getUserTimeLineRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userTimeLineDataReady(QVariant)));
}

void Instagram::getPopularFeed(QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="feed/popular/?people_teaser_supported=1&rank_token="+this->m_rank_token+"&ranked_content=true&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getPopularFeedRequest = new InstagramRequest();
    getPopularFeedRequest->request(target,NULL);
    QObject::connect(getPopularFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(popularFeedDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getMediaLikers(QString mediaId)
{
    InstagramRequest *getMediaLikersRequest = new InstagramRequest();
    getMediaLikersRequest->request("media/"+mediaId+"/likers/?",NULL);
    QObject::connect(getMediaLikersRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaLikersDataReady(QVariant)));
}

void Instagram::like(QString mediaId)
{
    InstagramRequest *likeRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",     mediaId);

    QString signature = likeRequest->generateSignature(data);
    likeRequest->request("media/"+mediaId+"/like/",signature.toUtf8());
    QObject::connect(likeRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(likeDataReady(QVariant)));
}

void Instagram::unLike(QString mediaId)
{
    InstagramRequest *unLikeRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("media_id",     mediaId);

    QString signature = unLikeRequest->generateSignature(data);
    unLikeRequest->request("media/"+mediaId+"/unlike/",signature.toUtf8());
    QObject::connect(unLikeRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unLikeDataReady(QVariant)));
}

void Instagram::getMediaComments(QString mediaId)
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *getMediaCommentsRequest = new InstagramRequest();
    getMediaCommentsRequest->request("media/"+mediaId+"/comments/?",NULL);
    QObject::connect(getMediaCommentsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(mediaCommentsDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::follow(QString userId)
{
    InstagramRequest *followRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = followRequest->generateSignature(data);
    followRequest->request("friendships/create/"+userId+"/",signature.toUtf8());
    QObject::connect(followRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(followDataReady(QVariant)));
}

void Instagram::unFollow(QString userId)
{
    InstagramRequest *unFollowRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = unFollowRequest->generateSignature(data);
    unFollowRequest->request("friendships/destroy/"+userId+"/",signature.toUtf8());
    QObject::connect(unFollowRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unFollowDataReady(QVariant)));
}

void Instagram::block(QString userId)
{
    InstagramRequest *blockRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = blockRequest->generateSignature(data);
    blockRequest->request("friendships/block/"+userId+"/",signature.toUtf8());
    QObject::connect(blockRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(blockDataReady(QVariant)));
}

void Instagram::unBlock(QString userId)
{
    InstagramRequest *unBlockRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = unBlockRequest->generateSignature(data);
    unBlockRequest->request("friendships/unblock/"+userId+"/",signature.toUtf8());
    QObject::connect(unBlockRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(unBlockDataReady(QVariant)));
}

void Instagram::userFriendship(QString userId)
{
    InstagramRequest *userFriendshipRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("user_id",     userId);

    QString signature = userFriendshipRequest->generateSignature(data);
    userFriendshipRequest->request("friendships/show/"+userId+"/",signature.toUtf8());
    QObject::connect(userFriendshipRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userFriendshipDataReady(QVariant)));
}

void Instagram::getLikedMedia(QString max_id)
{
    QString target ="feed/liked/";

    if(max_id.length() > 0)
    {
        target += "?max_id="+max_id;
    }

    InstagramRequest *getLikedMediaRequest = new InstagramRequest();
    getLikedMediaRequest->request(target,NULL);
    QObject::connect(getLikedMediaRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(likedMediaDataReady(QVariant)));
}

/*
 * Return json string
 * {
 *   "username":    STRING  Checking username,
 *   "available":   BOOL    Aviable to registration,
 *   "status":      STRING  Status of request,
 *   "error":       STRING  Error string if aviable
 *   }
 */
void Instagram::checkUsername(QString username)
{
    InstagramRequest *checkUsernameRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_csrftoken",   QString("missing"));
        data.insert("username",     username);

    QString signature = checkUsernameRequest->generateSignature(data);
    checkUsernameRequest->request("users/check_username/",signature.toUtf8());
    QObject::connect(checkUsernameRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(usernameCheckDataReady(QVariant)));
}
/*
 * Return JSON string
 * {
 *  "status": STRING    Status of request,
 *  "errors":{
 *            ARRAY     Array of errors if aviable
 *      "password":[],  STRING  Error message if password wrong if aviable
 *      "email":[],     STRING  Error message if email wrong if aviable
 *      "FIELD_ID":[]   STRING  Error message if FIELD_ID wrong if aviable
 *  },
 *  "account_created",  BOOL Status of creation account
 *  "created_user"      ARRAY Array of new user params
 *  }
 *
 */
void Instagram::createAccount(QString username, QString password, QString email)
{
    InstagramRequest *createAccountRequest = new InstagramRequest();
    QJsonObject data;
        data.insert("_uuid",               this->m_uuid);
        data.insert("_csrftoken",          QString("missing"));
        data.insert("username",            username);
        data.insert("first_name",          QString(""));
        data.insert("guid",                this->m_uuid);
        data.insert("device_id",           this->m_device_id);
        data.insert("email",               email);
        data.insert("force_sign_up_code",  QString(""));
        data.insert("qs_stamp",            QString(""));
        data.insert("password",            password);

    QString signature = createAccountRequest->generateSignature(data);
    createAccountRequest->request("accounts/create/",signature.toUtf8());
    QObject::connect(createAccountRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(createAccountDataReady(QVariant)));
}

void Instagram::searchUsername(QString username)
{
    InstagramRequest *searchUsernameRequest = new InstagramRequest();
    searchUsernameRequest->request("users/"+username+"/usernameinfo/", NULL);
    QObject::connect(searchUsernameRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchUsernameDataReady(QVariant)));
}

void Instagram::searchUsers(QString query)
{
    InstagramRequest *searchUsersRequest = new InstagramRequest();
    searchUsersRequest->request("users/search/?ig_sig_key_version=4&is_typeahead=true&query="+query+"&rank_token="+this->m_rank_token, NULL);
    QObject::connect(searchUsersRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchUsersDataReady(QVariant)));
}

void Instagram::searchTags(QString query)
{
    InstagramRequest *searchTagsRequest = new InstagramRequest();
    searchTagsRequest->request("tags/search/?is_typeahead=true&q="+query+"&rank_token="+this->m_rank_token, NULL);
    QObject::connect(searchTagsRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchTagsDataReady(QVariant)));
}

void Instagram::searchFBLocation(QString query)
{
    InstagramRequest *searchFBLocationRequest = new InstagramRequest();
    searchFBLocationRequest->request("fbsearch/places/?query="+query+"&rank_token="+this->m_rank_token, NULL);
    QObject::connect(searchFBLocationRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchFBLocationDataReady(QVariant)));
}

void Instagram::getLocationFeed(QString locationId, QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="feed/location/"+locationId+"/";

    if(max_id.length() > 0)
    {
        target += "?max_id="+max_id;
    }

    InstagramRequest *getLocationFeedRequest = new InstagramRequest();
    getLocationFeedRequest->request(target,NULL);
    QObject::connect(getLocationFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(getLocationFeedDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::searchLocation(QString latitude, QString longitude, QString query)
{
    QString target = "location_search/?rank_token="+this->m_rank_token+"&latitude="+latitude+"&longitude="+longitude;

    if(query.length() > 0)
    {
        target += "&search_query="+query;
    }
    else
    {
        target += "&timestamp="+QString::number(QDateTime::currentMSecsSinceEpoch());
    }

    InstagramRequest *searchLocationRequest = new InstagramRequest();
    searchLocationRequest->request(target, NULL);
    QObject::connect(searchLocationRequest,SIGNAL(replySrtingReady(QVariant)), this, SIGNAL(searchLocationDataReady(QVariant)));
}

void Instagram::getv2Inbox(QString cursor_id)
{
    QString target ="direct_v2/inbox/?use_unified_inbox=true";

    if(cursor_id.length() > 0)
    {
        target += "&cursor="+cursor_id;
    }

    InstagramRequest *getv2InboxRequest = new InstagramRequest();
    getv2InboxRequest->request(target,NULL);
    QObject::connect(getv2InboxRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(v2InboxDataReady(QVariant)));
}

void Instagram::directThread(QString threadId, QString cursor_id)
{
    QString target ="direct_v2/threads/"+threadId+"/?use_unified_inbox=true";

    if(cursor_id.length() > 0)
    {
        target += "&cursor="+cursor_id;
    }

    InstagramRequest *directThreadRequest = new InstagramRequest();
    directThreadRequest->request(target,NULL);

    QObject::connect(directThreadRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(directThreadReady(QVariant)));
}

void Instagram::directShare(QString mediaId, QString recipients, QString text)
{
    m_busy = true;
    emit busyChanged();

    //QString recipient_users = "\""+recipients+"\"";

    QString boundary = this->m_uuid;

    /*Body build*/
    QByteArray body = "";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"media_id\"\r\n\r\n";
    body += mediaId+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += this->m_uuid.replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text+"\r\n";

    body += "--"+boundary+"--";

    InstagramRequest *directMessageShare = new InstagramRequest();
    directMessageShare->directRquest("direct_v2/threads/broadcast/media_share/?media_type=photo",boundary, body);
    QObject::connect(directMessageShare,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(directShareReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::directMessage(QString recipients, QString text, QString thread_id)
{
    m_busy = true;
    emit busyChanged();

    QString boundary = this->m_uuid;

    QUuid uuid;

    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += uuid.createUuid().toString().replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
    body += "[\""+thread_id+"\"]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text+"\r\n";

    body += "--"+boundary+"--";

    InstagramRequest *directMessageRequest = new InstagramRequest();
    directMessageRequest->directRquest("direct_v2/threads/broadcast/text/",boundary, body);
    QObject::connect(directMessageRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(directMessageReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::directLike(QString recipients, QString thread_id)
{
    m_busy = true;
    emit busyChanged();

    QString boundary = this->m_uuid;

    QUuid uuid;

    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += uuid.createUuid().toString().replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
    body += "[\""+thread_id+"\"]\r\n";

    body += "--"+boundary+"--";

    InstagramRequest *directLikeRequest = new InstagramRequest();
    directLikeRequest->directRquest("direct_v2/threads/broadcast/like/",boundary, body);
    QObject::connect(directLikeRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(directLikeReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::changePassword(QString oldPassword, QString newPassword)
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *changePasswordRequest = new InstagramRequest();

    QJsonObject data;
        data.insert("_uuid",        this->m_uuid);
        data.insert("_uid",         this->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+this->m_token);
        data.insert("old_password", oldPassword);
        data.insert("new_password1", newPassword);
        data.insert("new_password2", newPassword);

    QString signature = changePasswordRequest->generateSignature(data);
    changePasswordRequest->request("accounts/change_password/",signature.toUtf8());
    QObject::connect(changePasswordRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(changePasswordReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::explore(QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="discover/explore/?";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *exploreRequest = new InstagramRequest();
    exploreRequest->request(target,NULL);
    QObject::connect(exploreRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(exploreDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::suggestions()
{
    m_busy = true;
    emit busyChanged();

    InstagramRequest *suggestionsRequest = new InstagramRequest();

    QUuid uuid;
    QJsonObject data;
        data.insert("phone_id", uuid.createUuid().toString());
        data.insert("_csrftoken", "Set-Cookie: csrftoken="+this->m_token);
        data.insert("module", "explore_people");
        data.insert("_uuid", this->m_uuid);
        data.insert("paginate", "true");
        data.insert("num_media", "3");

    QString signature = suggestionsRequest->generateSignature(data);
    suggestionsRequest->request("discover/ayml/",signature.toUtf8());
    QObject::connect(suggestionsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(suggestionsDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getRankedRecipients(QString query)
{
    QString target = "direct_v2/ranked_recipients/?mode=raven&show_threads=true&use_unified_inbox=true&";

    if(query.length() > 0)
    {
        target += "&query="+query;
    }
    else
    {
        target += "&query=nur";
    }

    InstagramRequest *getRankedRecipientsRequest = new InstagramRequest();
    getRankedRecipientsRequest->request(target, NULL);
    QObject::connect(getRankedRecipientsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(rankedRecipientsDataReady(QVariant)));
}

void Instagram::getRecentRecipients()
{
    InstagramRequest *getRecentRecipientsRequest = new InstagramRequest();
    getRecentRecipientsRequest->request("direct_share/recent_recipients/",NULL);
    QObject::connect(getRecentRecipientsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(recentRecipientsDataReady(QVariant)));
}

void Instagram::getUserFollowings(QString usernameId, QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="friendships/"+usernameId+"/following/?rank_token="+this->m_rank_token+"&ig_sig_key_version=4&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getUserFollowingsRequest = new InstagramRequest();
    getUserFollowingsRequest->request(target,NULL);
    QObject::connect(getUserFollowingsRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userFollowingsDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getUserFollowers(QString usernameId, QString max_id)
{
    m_busy = true;
    emit busyChanged();

    QString target ="friendships/"+usernameId+"/followers/?rank_token="+this->m_rank_token+"&ig_sig_key_version=4&";

    if(max_id.length() > 0)
    {
        target += "&max_id="+max_id;
    }

    InstagramRequest *getUserFollowersRequest = new InstagramRequest();
    getUserFollowersRequest->request(target,NULL);
    QObject::connect(getUserFollowersRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userFollowersDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getUserBlockedList()
{
    m_busy = true;
    emit busyChanged();

    QString target ="users/blocked_list/";

    InstagramRequest *getUserBlockedListRequest = new InstagramRequest();
    getUserBlockedListRequest->request(target,NULL);
    QObject::connect(getUserBlockedListRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userBlockedListDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getReelsTrayFeed()
{
    m_busy = true;
    emit busyChanged();

    QString target ="feed/reels_tray/";

    InstagramRequest *getReelsTrayFeedRequest = new InstagramRequest();
    getReelsTrayFeedRequest->request(target,NULL);
    QObject::connect(getReelsTrayFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(reelsTrayFeedDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

void Instagram::getUserReelsMediaFeed(QString user_id)
{
    m_busy = true;
    emit busyChanged();

    QString target = "feed/user/"+user_id+"/reel_media/";

    InstagramRequest *getUserReelsMediaFeedRequest = new InstagramRequest();
    getUserReelsMediaFeedRequest->request(target,NULL);
    QObject::connect(getUserReelsMediaFeedRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(userReelsMediaFeedDataReady(QVariant)));

    m_busy = false;
    emit busyChanged();
}

// Camera
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
    } else {
        emit imgRotated();
    }

    imgFile.close();
}

void Instagram::squareImg(QString filename)
{
    QImage image(filename);

    QFile imgFile(filename);
    imgFile.open(QIODevice::ReadWrite);

    if (image.height() > image.width()) {
        image = image.copy(0, (image.height()-image.width())/2, image.width(), image.width());

        if(!image.save(&imgFile,"JPG",100))
        {
            qDebug() << "NOT SAVE ON CROP";
        } else {
            emit imgSquared();
        }
    } else if (image.height() < image.width()) {
        image = image.copy((image.width()-image.height())/2, 0, image.height(), image.height());

        if(!image.save(&imgFile,"JPG",100))
        {
            qDebug() << "NOT SAVE ON CROP";
        } else {
            emit imgSquared();
        }
    }

    imgFile.close();
}

void Instagram::cropImg(QString filename, qreal propos)
{
    QImage image(filename);
    image = image.copy(0, image.height()*propos, image.width(), image.width());

    QFile imgFile(filename);
    imgFile.open(QIODevice::ReadWrite);

    if(!image.save(&imgFile,"JPG",100))
    {
        qDebug() << "NOT SAVE ON CROP";
    } else {
        emit imgCropped();
    }

    imgFile.close();
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
            emit imgScaled();
        }
    } else {
        emit imgScaled();
    }

    imgFile.close();
}
