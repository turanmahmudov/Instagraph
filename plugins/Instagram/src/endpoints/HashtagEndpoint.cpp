#include "HashtagEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"

namespace IG {

HashtagEndpoint::HashtagEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void HashtagEndpoint::getTagSectionFeed(const QString & tag, const QString & tab, int page,
                                        const QStringList & nextMediaIds, const QString & maxId) {
    auto builder = RequestBuilder::post("tags/{tag}/sections/")
                       .pathParam("tag", tag)
                       .param("tab", tab)
                       .param("page", page);

    if (!nextMediaIds.isEmpty()) {
        builder.param("next_media_ids", "[" + nextMediaIds.join(",") + "]");
    }

    if (!maxId.isEmpty()) {
        builder.param("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit tagSectionFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void HashtagEndpoint::searchTags(const QString & tag, const QString & rankToken) {
    auto request = RequestBuilder::get("tags/search/")
                       .queryParam("q", tag)
                       .queryParam("rank_token", rankToken)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit searchTagsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
