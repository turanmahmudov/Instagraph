#include "FeedEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QUuid>

namespace IG {

FeedEndpoint::FeedEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void FeedEndpoint::getTimelineFeed(const QString& maxId, const QString& seenPosts, 
                                   bool pullToRefresh, const QString& uuid,
                                   const QString& deviceId, const QString& csrfToken) {
    QString sessionUuid = QUuid::createUuid().toString();
    sessionUuid = sessionUuid.mid(1, sessionUuid.length() - 2);

    QString cleanUuid = uuid;
    cleanUuid.remove('{').remove('}');

    auto builder = RequestBuilder::post("feed/timeline/")
        .param("_uuid", cleanUuid)
        .param("_csrftoken", csrfToken)
        .param("is_prefetch", "0")
        .param("phone_id", deviceId)
        .param("device_id", cleanUuid)
        .param("client_session_id", sessionUuid)
        .param("battery_level", "25")
        .param("is_charging", "0")
        .param("will_sound_on", "1")
        .param("is_on_screen", "true")
        .param("timezone_offset", "0")
        .param("is_async_ads_in_headload_enabled", "0")
        .param("is_async_ads_double_request", "0")
        .param("is_async_ads_rti", "0")
        .param("rti_delivery_backend", "0")
        .unsigned_();

    if (!maxId.isEmpty()) {
        builder.param("reason", "pagination")
               .param("max_id", maxId)
               .param("is_pull_to_refresh", "0");
    } else if (pullToRefresh) {
        builder.param("reason", "pull_to_refresh")
               .param("is_pull_to_refresh", "1");
    } else {
        builder.param("reason", "cold_start_fetch")
               .param("is_pull_to_refresh", "0")
               .param("feed_view_info", "");
    }

    if (!seenPosts.isEmpty()) {
        builder.param("seen_posts", seenPosts);
    } else if (maxId.isEmpty()) {
        builder.param("seen_posts", "");
    }

    if (maxId.isEmpty()) {
        builder.param("unseen_posts", "");
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit timelineFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void FeedEndpoint::getUserFeed(const QString& userId, const QString& maxId, 
                               const QString& minTimestamp, const QString& rankToken) {
    auto builder = RequestBuilder::get("feed/user/{user_id}/")
        .pathParam("user_id", userId)
        .queryParam("rank_token", rankToken)
        .queryParam("ranked_content", "true");
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }
    if (!minTimestamp.isEmpty()) {
        builder.queryParam("min_timestamp", minTimestamp);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit userFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void FeedEndpoint::getPopularFeed(const QString& maxId, const QString& rankToken) {
    auto builder = RequestBuilder::get("feed/popular/")
        .queryParam("people_teaser_supported", "1")
        .queryParam("rank_token", rankToken)
        .queryParam("ranked_content", "true");
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit popularFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void FeedEndpoint::getExploreFeed(const QString& maxId, const QString& sessionId) {
    auto builder = RequestBuilder::get("discover/topical_explore/")
        .queryParam("is_prefetch", "false")
        .queryParam("omit_cover_media", "true")
        .queryParam("module", "explore_popular")
        .queryParam("reels_configuration", "hide_hero")
        .queryParam("use_sectional_payload", "true")
        .queryParam("timezone_offset", "0")
        .queryParam("cluster_id", "explore_all:0")
        .queryParam("include_fixed_destinations", "true")
        .queryParam("session_id", sessionId);
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit exploreFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void FeedEndpoint::getSuggestions(const QString& uuid, const QString& csrfToken) {
    QString phoneId = QUuid::createUuid().toString();
    phoneId = phoneId.mid(1, phoneId.length() - 2);

    auto request = RequestBuilder::post("discover/ayml/")
        .param("phone_id", phoneId)
        .param("_csrftoken", csrfToken)
        .param("module", "explore_people")
        .param("_uuid", uuid)
        .param("paginate", "true")
        .param("num_media", "3")
        .unsigned_()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit suggestionsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
