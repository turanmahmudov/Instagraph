#include "UsertagEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"

namespace IG {

UsertagEndpoint::UsertagEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void UsertagEndpoint::getUserTags(const QString & userId, const QString & maxId,
                                  const QString & minTimestamp, const QString & rankToken) {
    auto builder = RequestBuilder::get("usertags/{user_id}/feed/")
                       .pathParam("user_id", userId)
                       .queryParam("rank_token", rankToken)
                       .queryParam("ranked_content", "true");

    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }
    if (!minTimestamp.isEmpty()) {
        builder.queryParam("min_timestamp", minTimestamp);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit userTagsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void UsertagEndpoint::removeSelfTag(const QString & mediaId) {
    auto request = RequestBuilder::post("usertags/{media_id}/remove/")
                       .pathParam("media_id", mediaId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit selfTagRemoved(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
