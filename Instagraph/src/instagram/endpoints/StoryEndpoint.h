#ifndef INSTAGRAM_STORYENDPOINT_H
#define INSTAGRAM_STORYENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all story-related API operations.
 * 
 * This endpoint manages:
 * - Story tray feed
 * - User reels/stories
 * - Mark stories as seen
 * - User highlights
 */
class StoryEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit StoryEndpoint(ApiClient* client, QObject* parent = nullptr);

    // Story feeds
    void getReelsTrayFeed();
    void getUserReelsMediaFeed(const QString& userId);
    void getReelsMediaFeed(const QString& id);

    // Story actions
    void markStoryMediaSeen(const QString& reels);

    // Highlights
    void getUserHighlightFeed(const QString& userId);

Q_SIGNALS:
    void reelsTrayFeedReady(const QVariant& answer);
    void userReelsMediaFeedReady(const QVariant& answer);
    void reelsMediaFeedReady(const QVariant& answer);
    void storyMediaSeenReady(const QVariant& answer);
    void userHighlightFeedReady(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_STORYENDPOINT_H
