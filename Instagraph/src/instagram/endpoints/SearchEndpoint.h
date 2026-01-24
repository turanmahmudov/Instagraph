#ifndef INSTAGRAM_SEARCHENDPOINT_H
#define INSTAGRAM_SEARCHENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all search-related API operations (Facebook search).
 */
class SearchEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit SearchEndpoint(ApiClient* client, QObject* parent = nullptr);

    void recentSearches();
    void searchPlaces(const QString& query, const QString& rankToken = "");

Q_SIGNALS:
    void recentSearchesReady(const QVariant& answer);
    void searchPlacesReady(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_SEARCHENDPOINT_H
