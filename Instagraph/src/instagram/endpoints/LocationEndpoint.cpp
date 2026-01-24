#include "LocationEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QDateTime>

namespace IG {

LocationEndpoint::LocationEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void LocationEndpoint::getGeoMedia(const QString& usernameId) {
    auto request = RequestBuilder::get("maps/user/{username_id}/")
        .pathParam("username_id", usernameId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit geoMediaReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void LocationEndpoint::getLocationFeed(const QString& locationId, const QString& maxId) {
    auto builder = RequestBuilder::get("feed/location/{location_id}/")
        .pathParam("location_id", locationId);
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit locationFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void LocationEndpoint::searchLocation(const QString& lat, const QString& lng, 
                                      const QString& query, const QString& rankToken) {
    auto builder = RequestBuilder::get("location_search/")
        .queryParam("rank_token", rankToken)
        .queryParam("latitude", lat)
        .queryParam("longitude", lng);
    
    if (!query.isEmpty()) {
        builder.queryParam("search_query", query);
    } else {
        builder.queryParam("timestamp", QString::number(QDateTime::currentSecsSinceEpoch()));
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit searchLocationReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
