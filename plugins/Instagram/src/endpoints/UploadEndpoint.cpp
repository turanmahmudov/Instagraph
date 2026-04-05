#include "UploadEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace IG {

UploadEndpoint::UploadEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void UploadEndpoint::postImage(const QString & path, const QString & caption,
                               const QVariantMap & location, const QString & uploadId,
                               const QString & disableComments) {
    // Store upload state
    m_caption = caption;
    m_imagePath = path;
    m_location = location;
    m_disableComments = disableComments;

    // Open and read the image file
    QFile image(path);
    if (!image.open(QIODevice::ReadOnly)) {
        emit error("Image not found: " + path);
        return;
    }

    QByteArray dataStream = image.readAll();
    image.close();

    // Generate upload ID if not provided
    m_currentUploadId = uploadId;
    if (m_currentUploadId.isEmpty()) {
        m_currentUploadId = QString::number(QDateTime::currentMSecsSinceEpoch());
    }

    // TODO: File upload requires special handling in ApiClient
    // For now, emit error indicating this needs implementation
    emit error("File upload not yet implemented in new ApiClient pattern. Use "
               "legacy upload method.");
}

void UploadEndpoint::configurePhoto(const QString & uploadId) {
    QImage image(m_imagePath);
    if (image.isNull()) {
        emit error("Failed to load image for configuration: " + m_imagePath);
        return;
    }

    // Build device info
    QJsonObject device;
    device.insert("manufacturer", QString("Xiaomi"));
    device.insert("model", QString("HM 1SW"));
    device.insert("android_version", 18);
    device.insert("android_release", QString("4.3"));

    // Build extra info
    QJsonObject extra;
    extra.insert("source_width", image.width());
    extra.insert("source_height", image.height());

    // Build crop info
    QJsonArray cropOriginalSize;
    cropOriginalSize.append(image.width());
    cropOriginalSize.append(image.height());

    QJsonArray cropCenter;
    cropCenter.append(0.0);
    cropCenter.append(-0.0);

    QJsonObject edits;
    edits.insert("crop_original_size", cropOriginalSize);
    edits.insert("crop_zoom", 1.3333334);
    edits.insert("crop_center", cropCenter);

    // Build request
    auto builder = RequestBuilder::post("media/configure/")
                       .param("upload_id", uploadId)
                       .param("camera_model", "HM1S")
                       .param("source_type", 4)
                       .param("date_time_original",
                              QDateTime::currentDateTime().toString("yyyy:MM:dd HH:mm:ss"))
                       .param("camera_make", "XIAOMI")
                       .param("edits", edits)
                       .param("extra", extra)
                       .param("device", device)
                       .param("caption", m_caption)
                       .authenticated();

    // Add location if provided
    if (m_location.count() > 0 && m_location["name"].toString().length() > 0) {
        QJsonObject locationObj;
        QString eisk = m_location["external_id_source"].toString() + "_id";
        locationObj.insert(eisk, m_location["external_id"].toString());
        locationObj.insert("name", m_location["name"].toString());
        locationObj.insert("lat", m_location["lat"].toString());
        locationObj.insert("lng", m_location["lng"].toString());
        locationObj.insert("address", m_location["address"].toString());
        locationObj.insert("external_source", m_location["external_id_source"].toString());

        QJsonDocument doc(locationObj);
        QString strJson(doc.toJson(QJsonDocument::Compact));

        builder.param("location", strJson)
            .param("geotag_enabled", true)
            .param("media_latitude", m_location["lat"].toString())
            .param("posting_latitude", m_location["lat"].toString())
            .param("media_longitude", m_location["lng"].toString())
            .param("posting_longitude", m_location["lng"].toString())
            .param("altitude", QString::number(rand() % 10 + 800));
    }

    // Add disable comments if set
    if (m_disableComments == "1") {
        builder.param("disable_comments", "1");
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        // Clear state
        m_caption.clear();
        m_imagePath.clear();
        m_location.clear();

        if (response.ok()) {
            emit imageConfigured(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void UploadEndpoint::changeProfilePicture(const QString & photoPath) {
    // TODO: File upload requires special handling in ApiClient
    Q_UNUSED(photoPath);
    emit error("Profile picture upload not yet implemented in new ApiClient pattern");
}

} // namespace IG
