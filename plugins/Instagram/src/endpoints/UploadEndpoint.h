#ifndef INSTAGRAM_UPLOADENDPOINT_H
#define INSTAGRAM_UPLOADENDPOINT_H

#include <QObject>
#include <QSize>
#include <QVariant>
#include <QVariantMap>
#include <functional>

namespace IG {

class ApiClient;
class RequestBuilder;

/**
 * @brief Handles image uploads to Instagram
 *
 * This endpoint manages:
 * - Photo upload to rupload_igphoto
 * - Photo post with media/configure
 * - Video upload to rupload_igvideo and video post
 * - Profile picture change
 * - Upload progress tracking
 */
class UploadEndpoint : public QObject {
    Q_OBJECT
public:
    explicit UploadEndpoint(ApiClient * client, QObject * parent = nullptr);

    /**
     * @brief Upload and post an image
     * @param path Local path to the image file
     * @param caption Post caption
     * @param location Optional location data
     * @param uploadId Optional upload ID (auto-generated if empty)
     * @param disableComments "1" to disable comments, "0" otherwise
     */
    void postImage(const QString & path, const QString & caption, const QVariantMap & location,
                   const QString & uploadId = "", const QString & disableComments = "0");

    /**
     * @brief Upload and post a video
     * @param videoPath Local path to the MP4 file
     * @param coverPath Local path to the cover image
     * @param width Video width in pixels
     * @param height Video height in pixels
     * @param durationMs Video duration in milliseconds
     * @param caption Post caption
     * @param location Optional location data
     * @param disableComments "1" to disable comments, "0" otherwise
     */
    void postVideo(const QString & videoPath, const QString & coverPath, int width, int height,
                   qint64 durationMs, const QString & caption, const QVariantMap & location,
                   const QString & disableComments);

    /**
     * @brief Change user's profile picture
     * @param photoPath Local path to the photo file
     */
    void changeProfilePicture(const QString & photoPath);

signals:
    /**
     * @brief Emitted when image is successfully configured/posted
     * @param response API response with media details
     */
    void imageConfigured(const QVariant & response);

    /**
     * @brief Emitted when a video is posted
     * @param response API response with media details
     */
    void videoConfigured(const QVariant & response);

    /**
     * @brief Emitted during upload with progress percentage
     * @param percent Upload progress (0.0 - 100.0)
     */
    void uploadProgress(double percent);

    /**
     * @brief Emitted when profile picture is changed
     * @param response API response
     */
    void profilePictureChanged(const QVariant & response);

    /**
     * @brief Emitted on error
     */
    void error(const QString & message);

private:
    bool readJpeg(const QString & path, QByteArray & jpegData, QSize & size);
    void uploadPhoto(const QByteArray & jpegData, const QString & uploadId,
                     std::function<void()> onUploaded);
    void addLocation(RequestBuilder & builder) const;
    void configurePhoto(const QString & uploadId);
    void uploadVideo(const QByteArray & videoData, const QString & uploadId,
                     std::function<void()> onUploaded);
    void configureVideo(const QString & uploadId, int attempt);

    ApiClient * m_client;

    // Upload state
    QString m_caption;
    QSize m_imageSize;
    QVariantMap m_location;
    QString m_disableComments;
    QString m_uploadRequestId;

    // Video upload state
    QSize m_videoSize;
    qint64 m_videoDurationMs = 0;
};

} // namespace IG

#endif // INSTAGRAM_UPLOADENDPOINT_H
