#ifndef INSTAGRAM_LOCATIONENDPOINT_H
#define INSTAGRAM_LOCATIONENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all location-related API operations.
 */
class LocationEndpoint : public QObject {
    Q_OBJECT

public:
    explicit LocationEndpoint(ApiClient * client, QObject * parent = nullptr);

    void getGeoMedia(const QString & usernameId);
    void getLocationFeed(const QString & locationId, const QString & maxId = "");
    void getLocationSectionFeed(const QString & locationId, const QString & tab, int page,
                                const QStringList & nextMediaIds, const QString & maxId);
    void searchLocation(const QString & lat, const QString & lng, const QString & query = "",
                        const QString & rankToken = "");

Q_SIGNALS:
    void geoMediaReady(const QVariant & answer);
    void locationFeedReady(const QVariant & answer);
    void locationSectionFeedReady(const QVariant & answer);
    void searchLocationReady(const QVariant & answer);
    void error(const QString & message);

private:
    ApiClient * m_client;
};

} // namespace IG

#endif // INSTAGRAM_LOCATIONENDPOINT_H
