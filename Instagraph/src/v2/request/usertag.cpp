#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

//getUserTag
void Instagram::getUserTags(QString userId, QString max_id, QString minTimestamp)
{
    Q_D(Instagram);

    InstagramRequest *getUserTagsRequest =
        d->request("usertags/"+userId+"/feed/?"
                   "rank_token="+d->m_rank_token+"&"
                   "ranked_content=true" +
                   (max_id.length()>0 ?  "&max_id="+max_id : "" ) +
                   (minTimestamp.length()>0? "&min_timestamp="+minTimestamp : "" )
                   ,NULL, false, true);
    QObject::connect(getUserTagsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(userTagsDataReady(QVariant)));
}

void Instagram::removeSelftag(QString mediaId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_uid",         d->m_username_id);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *removeSelftagRequest =
        d->request("usertags/"+mediaId+"/remove/",signature.toUtf8());
    QObject::connect(removeSelftagRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(removeSelftagDone(QVariant)));
}

