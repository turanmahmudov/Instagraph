#include "StoryEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QJsonDocument>
#include <QJsonObject>

namespace IG {

StoryEndpoint::StoryEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void StoryEndpoint::getReelsTrayFeed() {
    auto request = RequestBuilder::get("feed/reels_tray/")
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit reelsTrayFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void StoryEndpoint::getUserReelsMediaFeed(const QString& userId) {
    auto request = RequestBuilder::get("feed/user/{user_id}/reel_media/")
        .pathParam("user_id", userId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit userReelsMediaFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void StoryEndpoint::getReelsMediaFeed(const QString& id) {
    auto request = RequestBuilder::post("feed/reels_media/")
        .param("user_ids", id)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit reelsMediaFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void StoryEndpoint::markStoryMediaSeen(const QString& reels) {
    QJsonDocument jDoc = QJsonDocument::fromJson(reels.toLatin1());
    QJsonObject liveVods;

    auto request = RequestBuilder::post("media/seen/")
        .queryParam("reel", "1")
        .queryParam("live_vod", "0")
        .param("reels", jDoc.object())
        .param("live_vods", liveVods)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit storyMediaSeenReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void StoryEndpoint::getUserHighlightFeed(const QString& userId) {
    auto request = RequestBuilder::get("highlights/{user_id}/highlights_tray/")
        .pathParam("user_id", userId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit userHighlightFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
