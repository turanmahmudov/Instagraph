#include "SearchEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"

namespace IG {

SearchEndpoint::SearchEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void SearchEndpoint::recentSearches() {
    auto request = RequestBuilder::get("fbsearch/recent_searches/")
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit recentSearchesReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void SearchEndpoint::searchPlaces(const QString& query, const QString& rankToken) {
    auto request = RequestBuilder::get("fbsearch/places/")
        .queryParam("rank_token", rankToken)
        .queryParam("query", query)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit searchPlacesReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
