#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>
#include <QUuid>

void Instagram::getExploreFeed(QString max_id, QString isPrefetch)
{
    Q_D(Instagram);
    InstagramRequest *getExploreRequest =
        d->request("discover/explore/?"
                   "is_prefetch="+isPrefetch+"&"
                   "is_from_promote=false&"
                   "session_id=" + d->m_token +
                   "&module=explore_popular" +
                   (max_id.length()>0 ? "&max_id="+max_id : "" )
                   ,NULL);
    QObject::connect(getExploreRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(exploreFeedDataReady(QVariant)));
}

void Instagram::getSuggestions()
{
    Q_D(Instagram);

    QUuid uuid;
    QJsonObject data;
        data.insert("phone_id", uuid.createUuid().toString());
        data.insert("_csrftoken", "Set-Cookie: csrftoken="+d->m_token);
        data.insert("module", "explore_people");
        data.insert("_uuid", d->m_uuid);
        data.insert("paginate", "true");
        data.insert("num_media", "3");

    QString signature = InstagramRequest::generateSignature(data);

    InstagramRequest *getSuggestionsRequest =
        d->request("discover/ayml/",signature.toUtf8());
    QObject::connect(getSuggestionsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(suggestionsFeedDataReady(QVariant)));
}
