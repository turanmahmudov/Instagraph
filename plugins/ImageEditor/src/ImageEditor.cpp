#include "ImageEditor.h"
#include <QImage>
#include <QFile>
#include <QTransform>
#include <QDebug>

ImageEditor::ImageEditor(QObject* parent)
    : QObject(parent)
{
}

void ImageEditor::rotateImage(const QString& filename, qreal degrees) {
    QImage image(filename);
    if (image.isNull()) {
        emit error("Failed to load image: " + filename);
        return;
    }

    QTransform rot;
    rot.rotate(degrees);
    image = image.transformed(rot);

    QFile imgFile(filename);
    if (!imgFile.open(QIODevice::WriteOnly)) {
        emit error("Failed to open file for writing: " + filename);
        return;
    }

    if (!image.save(&imgFile, "JPG", 100)) {
        qDebug() << "Failed to save rotated image";
        emit error("Failed to save rotated image");
    } else {
        emit rotated();
    }

    imgFile.close();
}

void ImageEditor::cropImage(const QString& filename, bool squared, bool isRotated) {
    QImage image(filename);
    if (image.isNull()) {
        emit error("Failed to load image: " + filename);
        return;
    }

    if (!isRotated) {
        QTransform rot;
        rot.rotate(90);
        image = image.transformed(rot);
    }

    int min_size = qMin(image.width(), image.height());
    int max_size = qMax(image.width(), image.height());

    if (squared) {
        if (isRotated) {
            image = image.copy(max_size / 4, 0, min_size, min_size);
        } else {
            image = image.copy(0, (max_size - min_size) / 2, min_size, min_size);
        }
    } else {
        if (isRotated) {
            int size54 = max_size * (5.0 / 4.0);
            image = image.copy(0, max_size / 4, size54, min_size);
        } else {
            int size54 = min_size * 5 / 4;
            image = image.copy(0, (max_size - size54) / 2, min_size, size54);
        }
    }

    QFile imgFile(filename);
    if (!imgFile.open(QIODevice::WriteOnly)) {
        emit error("Failed to open file for writing: " + filename);
        return;
    }

    if (!image.save(&imgFile, "JPG", 100)) {
        qDebug() << "Failed to save cropped image";
        emit error("Failed to save cropped image");
    } else {
        emit cropped();
    }

    imgFile.close();
}

void ImageEditor::cropImage(const QString& inFilename, const QString& outFilename, int topSpace, bool squared) {
    QImage image(inFilename);
    if (image.isNull()) {
        emit error("Failed to load image: " + inFilename);
        return;
    }

    int min_size = qMin(image.width(), image.height());

    if (squared) {
        image = image.copy(0, topSpace, min_size, min_size);
    } else {
        int size54 = min_size * 5 / 4;
        image = image.copy(0, topSpace, min_size, size54);
    }

    if (!image.save(outFilename)) {
        qDebug() << "Failed to save cropped image to" << outFilename;
        emit error("Failed to save cropped image");
    } else {
        emit cropped();
    }
}

void ImageEditor::scaleImage(const QString& filename) {
    QImage image(filename);
    if (image.isNull()) {
        emit error("Failed to load image: " + filename);
        return;
    }

    if (image.width() > 800) {
        int w_s = image.width() / 800;
        int s_w = image.width() / w_s;
        int s_h = image.height() / w_s;

        image = image.scaled(s_w, s_h, Qt::KeepAspectRatio);

        QFile imgFile(filename);
        if (!imgFile.open(QIODevice::WriteOnly)) {
            emit error("Failed to open file for writing: " + filename);
            return;
        }

        if (!image.save(&imgFile, "JPG", 100)) {
            qDebug() << "Failed to save scaled image";
            emit error("Failed to save scaled image");
        } else {
            emit scaled();
        }

        imgFile.close();
    } else {
        emit scaled();
    }
}
