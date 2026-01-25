#include "HashtagEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"

namespace IG {

HashtagEndpoint::HashtagEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void HashtagEndpoint::getTagFeed(const QString& tag, const QString& maxId, const QString& rankToken) {
    auto builder = RequestBuilder::get("feed/tag/{tag}/")
        .pathParam("tag", tag)
        .queryParam("rank_token", rankToken)
        .queryParam("ranked_content", "true");
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit tagFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void HashtagEndpoint::searchTags(const QString& tag, const QString& rankToken) {
    auto request = RequestBuilder::get("tags/search/")
        .queryParam("q", tag)
        .queryParam("rank_token", rankToken)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit searchTagsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
