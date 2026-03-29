#ifndef INSTAGRAM_HASHTAGENDPOINT_H
#define INSTAGRAM_HASHTAGENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all hashtag-related API operations.
 */
class HashtagEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit HashtagEndpoint(ApiClient* client, QObject* parent = nullptr);

    void getTagFeed(const QString& tag, const QString& maxId = "", const QString& rankToken = "");
    void getTagSectionFeed(const QString& tag, const QString& tab, int page,
                           const QStringList& nextMediaIds, const QString& maxId);
    void searchTags(const QString& tag, const QString& rankToken = "");

Q_SIGNALS:
    void tagFeedReady(const QVariant& answer);
    void tagSectionFeedReady(const QVariant& answer);
    void searchTagsReady(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_HASHTAGENDPOINT_H
