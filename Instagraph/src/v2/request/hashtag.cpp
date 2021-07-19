#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::getTagFeed(QString tag, QString max_id)
{
    Q_D(Instagram);

    InstagramRequest *getTagFeedRequest =
        d->request("feed/tag/"+tag.toUtf8()+
                   "/?rank_token="+d->m_rank_token +
                   "&ranked_content=true"+
                   (max_id.length()>0 ? "&max_id="+max_id : "" )
                   ,NULL);
    QObject::connect(getTagFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(tagFeedDataReady(QVariant)));
}


void Instagram::searchTags(QString tag)
{
    Q_D(Instagram);

    InstagramRequest *searchTagsRequest =
        d->request("tags/search/?q=" + tag.toUtf8() +
                   "&rank_token=" + d->m_rank_token
                   ,NULL,false,true);
    QObject::connect(searchTagsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(searchTagsDataReady(QVariant)));
}
