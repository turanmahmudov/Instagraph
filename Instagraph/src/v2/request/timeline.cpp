#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>
#include <QUuid>
#include <QUrl>
#include <QUrlQuery>

void Instagram::getTimelineFeed(QString max_id, QString seen_posts, bool pullToRefresh)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    QUuid s_uuid;
    QString s_uuid_id = s_uuid.createUuid().toString();
    s_uuid_id.remove('{').remove('}');

    QString uuid = d->m_uuid;
    uuid.remove('{').remove('}');

    QUrlQuery data;
    data.addQueryItem("_uuid",        uuid);
    data.addQueryItem("_csrftoken",   d->m_token);
    data.addQueryItem("is_prefetch", "0");
    data.addQueryItem("phone_id", d->m_device_id);
    data.addQueryItem("device_id", uuid);
    data.addQueryItem("client_session_id", s_uuid_id);
    data.addQueryItem("battery_level", "25");
    data.addQueryItem("is_charging", "0");
    data.addQueryItem("will_sound_on", "1");
    data.addQueryItem("is_on_screen", "true");
    data.addQueryItem("timezone_offset", "0");

    data.addQueryItem("is_async_ads_in_headload_enabled", "0");
    data.addQueryItem("is_async_ads_double_request", "0");
    data.addQueryItem("is_async_ads_rti", "0");
    data.addQueryItem("rti_delivery_backend", "0");

    if (max_id.length() > 0) {
        data.addQueryItem("reason", "pagination");
        data.addQueryItem("max_id", max_id);
        data.addQueryItem("is_pull_to_refresh", "0");
    } else if (pullToRefresh == true) {
        data.addQueryItem("reason", "pull_to_refresh");
        data.addQueryItem("is_pull_to_refresh", "1");
    } else {
        data.addQueryItem("reason", "cold_start_fetch");
        data.addQueryItem("is_pull_to_refresh", "0");

        data.addQueryItem("feed_view_info", "");
    }

    if (seen_posts.length() > 0) {
        data.addQueryItem("seen_posts", seen_posts);
    } else if (max_id.length() == 0) {
        data.addQueryItem("seen_posts", "");
    }

    if (max_id.length() == 0) {
        data.addQueryItem("unseen_posts", "");
    }
    InstagramRequest *getTimeLineFeedRequest =
        d->timelineRequest("feed/timeline/?", data.toString().toUtf8(), d->m_uuid);

    QObject::connect(getTimeLineFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(timelineFeedDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}

//getUserTimeLine
void Instagram::getUserFeed(QString userID, QString max_id, QString minTimestamp)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    QString target = "feed/user/"+userID+"/?"
                     "rank_token="+d->m_rank_token +
                     (max_id.length()>0 ?  "&max_id="+max_id  : "" ) +
                     (minTimestamp.length()>0? "&min_timestamp="+minTimestamp : "" ) +
                     "&ranked_content=true";


    InstagramRequest *getUserFeedRequest = d->request(target,NULL);
    QObject::connect(getUserFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(userFeedDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}
