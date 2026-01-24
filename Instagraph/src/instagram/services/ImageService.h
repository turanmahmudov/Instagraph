#ifndef INSTAGRAM_IMAGESERVICE_H
#define INSTAGRAM_IMAGESERVICE_H

#include <QObject>
#include <QString>

namespace IG {

/**
 * @brief Image manipulation service for Instagram uploads.
 * 
 * Provides image rotation, cropping, and scaling operations
 * needed for Instagram media uploads.
 */
class ImageService : public QObject {
    Q_OBJECT
public:
    explicit ImageService(QObject* parent = nullptr);

    /**
     * @brief Rotate an image by specified degrees
     * @param filename Path to image file
     * @param degrees Rotation angle in degrees
     */
    void rotateImage(const QString& filename, qreal degrees);

    /**
     * @brief Crop image to square or 5:4 ratio
     * @param filename Path to image file
     * @param squared If true, crop to square; otherwise 5:4 ratio
     * @param isRotated If image was previously rotated
     */
    void cropImage(const QString& filename, bool squared, bool isRotated = true);

    /**
     * @brief Crop image with custom parameters
     * @param inFilename Input file path
     * @param outFilename Output file path
     * @param topSpace Top offset for cropping
     * @param squared If true, crop to square
     */
    void cropImage(const QString& inFilename, const QString& outFilename, int topSpace, bool squared);

    /**
     * @brief Scale image if width > 800px
     * @param filename Path to image file
     */
    void scaleImage(const QString& filename);

signals:
    void rotated();
    void cropped();
    void scaled();
    void squared();
    void error(const QString& message);
};

} // namespace IG

#endif // INSTAGRAM_IMAGESERVICE_H
