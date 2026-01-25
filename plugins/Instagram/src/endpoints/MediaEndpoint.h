#ifndef INSTAGRAM_MEDIAENDPOINT_H
#define INSTAGRAM_MEDIAENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all media-related API operations.
 * 
 * This endpoint manages:
 * - Like/unlike media
 * - Comments (post, delete, like, unlike)
 * - Media info and editing
 * - Save/unsave media
 * - Media comments settings
 */
class MediaEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit MediaEndpoint(ApiClient* client, QObject* parent = nullptr);

    // Like operations
    void like(const QString& mediaId, const QString& module = "feed_contextual_post");
    void unlike(const QString& mediaId, const QString& module = "feed_contextual_post");
    void getLikedFeed(const QString& maxId = "");
    void getLikedMedia(const QString& maxId = "");
    void getMediaLikers(const QString& mediaId);

    // Media info and editing
    void getInfo(const QString& mediaId);
    void edit(const QString& mediaId, const QString& captionText = "", 
              const QString& mediaType = "PHOTO");
    void deleteMedia(const QString& mediaId, const QString& mediaType = "PHOTO");

    // Comments
    void postComment(const QString& mediaId, const QString& commentText,
                     const QString& replyCommentId = "", 
                     const QString& module = "comments_feed_timeline");
    void deleteComment(const QString& mediaId, const QString& commentId);
    void likeComment(const QString& commentId);
    void unlikeComment(const QString& commentId);
    void getComments(const QString& mediaId, const QString& maxId = "");

    // Comments settings
    void enableComments(const QString& mediaId);
    void disableComments(const QString& mediaId);

    // Save operations
    void save(const QString& mediaId);
    void unsave(const QString& mediaId);
    void getSavedFeed(const QString& maxId = "");

Q_SIGNALS:
    void likeReady(const QVariant& answer);
    void unlikeReady(const QVariant& answer);
    void likedFeedReady(const QVariant& answer);
    void likedMediaReady(const QVariant& answer);
    void mediaLikersReady(const QVariant& answer);
    void mediaInfoReady(const QVariant& answer);
    void mediaEdited(const QVariant& answer);
    void mediaDeleted(const QVariant& answer);
    void commentPosted(const QVariant& answer);
    void commentDeleted(const QVariant& answer);
    void commentLiked(const QVariant& answer);
    void commentUnliked(const QVariant& answer);
    void commentsReady(const QVariant& answer);
    void commentsEnabled(const QVariant& answer);
    void commentsDisabled(const QVariant& answer);
    void mediaSaved(const QVariant& answer);
    void mediaUnsaved(const QVariant& answer);
    void savedFeedReady(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_MEDIAENDPOINT_H
