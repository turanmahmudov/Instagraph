#ifndef INSTAGRAM_UPLOADENDPOINT_H
#define INSTAGRAM_UPLOADENDPOINT_H

#include <QObject>
#include <QVariant>
#include <QVariantMap>
#include <QImage>

namespace IG {

class ApiClient;

/**
 * @brief Handles image uploads to Instagram
 * 
 * This endpoint manages:
 * - Photo uploads with configurePhoto step
 * - Upload progress tracking
 * 
 * Note: UploadEndpoint requires special handling for file uploads
 * which is currently not fully supported by the new pattern.
 * File upload functionality needs to be added to ApiClient.
 */
class UploadEndpoint : public QObject {
    Q_OBJECT
public:
    explicit UploadEndpoint(ApiClient* client, QObject* parent = nullptr);

    /**
     * @brief Upload and post an image
     * @param path Local path to the image file
     * @param caption Post caption
     * @param location Optional location data
     * @param uploadId Optional upload ID (auto-generated if empty)
     * @param disableComments "1" to disable comments, "0" otherwise
     */
    void postImage(const QString& path, const QString& caption, const QVariantMap& location,
                   const QString& uploadId = "", const QString& disableComments = "0");

    /**
     * @brief Change user's profile picture
     * @param photoPath Local path to the photo file
     */
    void changeProfilePicture(const QString& photoPath);

signals:
    /**
     * @brief Emitted when image is successfully configured/posted
     * @param response API response with media details
     */
    void imageConfigured(const QVariant& response);

    /**
     * @brief Emitted during upload with progress percentage
     * @param percent Upload progress (0.0 - 100.0)
     */
    void uploadProgress(double percent);

    /**
     * @brief Emitted when profile picture is changed
     * @param response API response
     */
    void profilePictureChanged(const QVariant& response);

    /**
     * @brief Emitted on error
     */
    void error(const QString& message);

private:
    void configurePhoto(const QString& uploadId);

    ApiClient* m_client;

    // Upload state
    QString m_caption;
    QString m_imagePath;
    QVariantMap m_location;
    QString m_disableComments;
    QString m_currentUploadId;
};

} // namespace IG

#endif // INSTAGRAM_UPLOADENDPOINT_H
