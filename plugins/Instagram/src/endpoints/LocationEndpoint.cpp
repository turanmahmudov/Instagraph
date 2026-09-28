#include "LocationEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QDateTime>

namespace IG {

LocationEndpoint::LocationEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void LocationEndpoint::getLocationSectionFeed(const QString & locationId, const QString & tab,
                                              int page, const QStringList & nextMediaIds,
                                              const QString & maxId) {
    auto builder = RequestBuilder::post("locations/{location_id}/sections/")
                       .pathParam("location_id", locationId)
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
            emit locationSectionFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void LocationEndpoint::searchLocation(const QString & lat, const QString & lng,
                                      const QString & query, const QString & rankToken) {
    auto builder = RequestBuilder::get("location_search/")
                       .queryParam("rank_token", rankToken)
                       .queryParam("latitude", lat)
                       .queryParam("longitude", lng);

    if (!query.isEmpty()) {
        builder.queryParam("search_query", query);
    } else {
        builder.queryParam("timestamp", QString::number(QDateTime::currentSecsSinceEpoch()));
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit searchLocationReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
