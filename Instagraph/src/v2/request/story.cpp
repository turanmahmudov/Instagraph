#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

void Instagram::getReelsTrayFeed()
{
    Q_D(Instagram);

    InstagramRequest *getReelsTrayFeedRequest =
        d->request("feed/reels_tray/"
                   ,NULL);
    QObject::connect(getReelsTrayFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(reelsTrayFeedDataReady(QVariant)));
}

void Instagram::getUserReelsMediaFeed(QString userId)
{
    Q_D(Instagram);

    InstagramRequest *getUserReelsMediaFeedRequest =
        d->request("feed/user/"+userId+"/reel_media/"
                   ,NULL,false,true);
    QObject::connect(getUserReelsMediaFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(userReelsMediaFeedDataReady(QVariant)));
}

void Instagram::getReelsMediaFeed(QString id)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("user_ids", id);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *getReelsMediaFeed =
        d->request("feed/reels_media/", signature.toUtf8());
    QObject::connect(getReelsMediaFeed,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(reelsMediaFeedDataReady(QVariant)));
}

void Instagram::markStoryMediaSeen(QString reels)
{
    Q_D(Instagram);

    QJsonDocument jDoc = QJsonDocument::fromJson(reels.toLatin1());
    QJsonObject live_vods;

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("reels",        jDoc.object());
        data.insert("live_vods",    live_vods);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *markStoryMediaSeenRequest =
        d->request("media/seen/?reel=1&live_vod=0", signature.toUtf8());
    QObject::connect(markStoryMediaSeenRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(markStoryMediaSeenDataReady(QVariant)));
}
