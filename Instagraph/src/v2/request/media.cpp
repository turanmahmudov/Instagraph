#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>
#include <QUuid>

void Instagram::like(QString mediaId, QString module)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("media_id",     mediaId);
        data.insert("radio-type",   "wifi-none");
        data.insert("module_name",  module);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *likeRequest =
        d->request("media/"+mediaId+"/like/",signature.toUtf8());
    QObject::connect(likeRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(likeDataReady(QVariant)));
}

void Instagram::unLike(QString mediaId, QString module)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("media_id",     mediaId);
        data.insert("radio-type",   "wifi-none");
        data.insert("module_name",  module);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *unLikeRequest =
        d->request("media/"+mediaId+"/unlike/",signature.toUtf8());
    QObject::connect(unLikeRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(unLikeDataReady(QVariant)));
}

void Instagram::getLikedFeed(QString max_id)
{
    Q_D(Instagram);

    InstagramRequest *getLikedFeedRequest =
        d->request("feed/liked/"
                   + (max_id.length()>0 ? "?max_id="+max_id : "")
                   ,NULL);
    QObject::connect(getLikedFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(likedFeedDataReady(QVariant)));
}

void Instagram::getInfoMedia(QString mediaId)
{
    Q_D(Instagram);

    InstagramRequest *infoMediaRequest =
        d->request("media/"+mediaId+"/info/?",NULL,false,true);
    QObject::connect(infoMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(mediaInfoReady(QVariant)));
}

void Instagram::deleteMedia(QString mediaId, QString mediaType)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("media_id",    mediaId);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *deleteMediaRequest =
        d->request("media/"+mediaId+"/delete/?"
                   "media_type=" + mediaType
                   ,signature.toUtf8());
    QObject::connect(deleteMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(mediaDeleted(QVariant)));
}

void Instagram::editMedia(QString mediaId, QString captionText, QString mediaType)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("caption_text", captionText);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *editMediaRequest =
        d->request("media/"+mediaId+"/edit_media/"
                   ,signature.toUtf8());
    QObject::connect(editMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(mediaEdited(QVariant)));
}

void Instagram::comment(QString mediaId, QString commentText, QString replyCommentId ,QString module)
{
    Q_D(Instagram);

    QUuid uuid;

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("comment_text", commentText);
        data.insert("containermoudle", module);
        data.insert("idempotence_token", uuid.createUuid().toString());
        data.insert("radio-type",   "wifi-none");
    if(replyCommentId != "" && replyCommentId.at(0) == '@')
        data.insert("replied_to_comment_id", replyCommentId);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *postCommentRequest =
        d->request("media/"+mediaId+"/comment/",signature.toUtf8());
    QObject::connect(postCommentRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(commentPosted(QVariant)));
}

void Instagram::deleteComment(QString mediaId, QString commentId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        //data.insert("caption_text", captionText);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *deleteCommentRequest =
        d->request("media/"+mediaId+"/comment/"+commentId+"/delete/",signature.toUtf8());
    QObject::connect(deleteCommentRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(commentDeleted(QVariant)));
}

void Instagram::likeComment(QString commentId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *likeCommentRequest =
        d->request("media/"+commentId+"/comment_like/",signature.toUtf8());
    QObject::connect(likeCommentRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(commentLiked(QVariant)));
}

void Instagram::unlikeComment(QString commentId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *unlikeCommentRequest =
        d->request("media/"+commentId+"/comment_unlike/",signature.toUtf8());
    QObject::connect(unlikeCommentRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(commentUnliked(QVariant)));
}

void Instagram::getComments(QString mediaId, QString max_id)
{
    Q_D(Instagram);

    InstagramRequest *getMediaCommentsRequest =
        d->request("media/"+mediaId+"/comments/?can_support_threading=true" +
                   (max_id.length()>0 ? "&min_id="+max_id : "")
                   ,NULL,false,true);
    QObject::connect(getMediaCommentsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(mediaCommentsDataReady(QVariant)));
}

void Instagram::getLikedMedia(QString max_id)
{
    Q_D(Instagram);

    InstagramRequest *getLikedMediaRequest =
        d->request("feed/liked/" +
                   (max_id.length()>0 ? "?max_id="+max_id : "")
                   ,NULL,false,true);

    QObject::connect(getLikedMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(likedMediaDataReady(QVariant)));
}

void Instagram::getMediaLikers(QString mediaId)
{
    Q_D(Instagram);

    InstagramRequest *getMediaLikersRequest =
        d->request("media/"+mediaId+"/likers/", NULL, false, true);
    QObject::connect(getMediaLikersRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(mediaLikersDataReady(QVariant)));
}

void Instagram::enableMediaComments(QString mediaId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *enableMediaCommentsRequest =
        d->request("media/"+mediaId+"/enable_comments/",signature.toUtf8());
    QObject::connect(enableMediaCommentsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(enableMediaCommentsDataReady(QVariant)));
}

void Instagram::disableMediaComments(QString mediaId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *disableMediaCommentsRequest =
        d->request("media/"+mediaId+"/disable_comments/",signature.toUtf8());
    QObject::connect(disableMediaCommentsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(disableMediaCommentsDataReady(QVariant)));
}

void Instagram::saveMedia(QString mediaId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *saveMediaRequest =
        d->request("media/"+mediaId+"/save/",signature.toUtf8());
    QObject::connect(saveMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(saveMediaDataReady(QVariant)));
}

void Instagram::unsaveMedia(QString mediaId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *saveMediaRequest =
        d->request("media/"+mediaId+"/unsave/",signature.toUtf8());
    QObject::connect(saveMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(unsaveMediaDataReady(QVariant)));
}

void Instagram::getSavedFeed(QString max_id)
{
    Q_D(Instagram);

    InstagramRequest *savedFeedRequest =
        d->request("feed/saved/" +
                   (max_id.length()>0 ?  "?max_id="+max_id  : "" ),NULL,false,true);

    QObject::connect(savedFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(savedFeedDataReady(QVariant)));
}
