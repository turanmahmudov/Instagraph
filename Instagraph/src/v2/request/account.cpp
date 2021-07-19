#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::changeProfilePicture(QFile *photo)
{

}

void Instagram::removeProfilePicture()
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *removeProfilePictureRequest =
        d->request("accounts/remove_profile_picture/",signature.toUtf8());
    QObject::connect(removeProfilePictureRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(profilePictureDeleted(QVariant)));
}

void Instagram::setPrivateAccount()
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *setPrivateRequest =
        d->request("accounts/set_private/",signature.toUtf8());
    QObject::connect(setPrivateRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(setProfilePrivate(QVariant)));
}

void Instagram::setPublicAccount()
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *setPublicRequest =
        d->request("accounts/set_public/",signature.toUtf8());
    QObject::connect(setPublicRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(setProfilePublic(QVariant)));
}

//getProfileData
void Instagram::getCurrentUser()
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    InstagramRequest *getCurrentUserRequest =
        d->request("accounts/current_user/?edit=true",NULL,false,true);
    QObject::connect(getCurrentUserRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(currentUserDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
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
    Q_D(Instagram);

    getCurrentUser();

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
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("external_url", url);
        data.insert("phone_number", phone);
        data.insert("username",     d->m_username);
        data.insert("first_name",    first_name);
        data.insert("biography",    biography);
        data.insert("email",        email);
        data.insert("gender",       gen_string);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *editProfileRequest =
        d->request("accounts/edit_profile/?edit=true",signature.toUtf8());
    QObject::connect(editProfileRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(editDataReady(QVariant)));
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
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_csrftoken",   QString("missing"));
        data.insert("username",     username);
        data.insert("_uid",         d->m_username_id);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *checkUsernameRequest =
        d->request("users/check_username/",signature.toUtf8());
    QObject::connect(checkUsernameRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(usernameCheckDataReady(QVariant)));
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
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",               d->m_uuid);
        data.insert("_csrftoken",          QString("missing"));
        data.insert("username",            username);
        data.insert("first_name",          QString(""));
        data.insert("guid",                d->m_uuid);
        data.insert("device_id",           d->m_device_id);
        data.insert("email",               email);
        data.insert("force_sign_up_code",  QString(""));
        data.insert("qs_stamp",            QString(""));
        data.insert("password",            password);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *createAccountRequest =
        d->request("accounts/create/",signature.toUtf8());
    QObject::connect(createAccountRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(createAccountDataReady(QVariant)));
}
