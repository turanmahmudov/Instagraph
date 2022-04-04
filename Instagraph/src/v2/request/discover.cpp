#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>
#include <QUuid>

void Instagram::getExploreFeed(QString max_id)
{
    Q_D(Instagram);
    InstagramRequest *getExploreRequest =
        d->request("discover/topical_explore/?"
                   "is_prefetch=false&"
                   "omit_cover_media=true&"
                   "module=explore_popular&"
                   "reels_configuration=hide_hero&"
                   "use_sectional_payload=true&"
                   "timezone_offset=0&"
                   "cluster_id=explore_all:0&"
                   "include_fixed_destinations=true&"
                   "session_id=" + d->m_token +
                   (max_id.length()>0 ? "&max_id="+max_id : "" )
                   ,NULL, false, true);
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
