#ifndef INSTAGRAM_FEEDENDPOINT_H
#define INSTAGRAM_FEEDENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all feed-related API operations.
 *
 * This endpoint manages:
 * - Timeline feed
 * - User feed
 * - Popular feed
 * - Explore/discover feed
 * - Suggestions
 */
class FeedEndpoint : public QObject {
    Q_OBJECT

public:
    explicit FeedEndpoint(ApiClient * client, QObject * parent = nullptr);

    // Timeline
    void getTimelineFeed(const QString & maxId = "", const QString & seenPosts = "",
                         bool pullToRefresh = false, const QString & uuid = "",
                         const QString & deviceId = "", const QString & csrfToken = "");
    void getUserFeed(const QString & userId, const QString & maxId = "",
                     const QString & minTimestamp = "", const QString & rankToken = "");

    // Popular/Explore
    void getExploreFeed(const QString & maxId = "", const QString & sessionId = "");

    // Suggestions
    void getSuggestions(const QString & uuid = "", const QString & csrfToken = "");

    // Media seen

Q_SIGNALS:
    void timelineFeedReady(const QVariant & answer);
    void userFeedReady(const QVariant & answer);
    void exploreFeedReady(const QVariant & answer);
    void suggestionsReady(const QVariant & answer);
    void error(const QString & message);

private:
    ApiClient * m_client;
};

} // namespace IG

#endif // INSTAGRAM_FEEDENDPOINT_H
