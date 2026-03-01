#ifndef IMAGEEDITOR_H
#define IMAGEEDITOR_H

#include <QObject>
#include <QString>

/**
 * @brief Image manipulation service for preparing images.
 * 
 * Provides image rotation, cropping, and scaling operations.
 * Exposed directly to QML as a creatable type.
 */
class ImageEditor : public QObject {
    Q_OBJECT
public:
    explicit ImageEditor(QObject* parent = nullptr);

    /**
     * @brief Rotate an image by specified degrees
     * @param filename Path to image file
     * @param degrees Rotation angle in degrees
     */
    Q_INVOKABLE void rotateImage(const QString& filename, qreal degrees);

    /**
     * @brief Crop image to square (squared=true) or 5:4 ratio
     * @param filename Path to image file
     * @param squared If true, crop to square; otherwise 5:4 ratio
     * @param isRotated If image was previously rotated
     */
    Q_INVOKABLE void cropImage(const QString& filename, bool squared, bool isRotated = true);

    /**
     * @brief Crop image with custom parameters
     * @param inFilename Input file path
     * @param outFilename Output file path
     * @param topSpace Top offset for cropping
     * @param squared If true, crop to square
     */
    Q_INVOKABLE void cropImage(const QString& inFilename, const QString& outFilename, int topSpace, bool squared);

    /**
     * @brief Scale image if width > 800px
     * @param filename Path to image file
     */
    Q_INVOKABLE void scaleImage(const QString& filename);

signals:
    void rotated();
    void cropped();
    void scaled();
    void squared();
    void error(const QString& message);
};

#endif // IMAGEEDITOR_H
