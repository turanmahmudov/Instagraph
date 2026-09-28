#include "UploadEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include "../utils/Constants.h"
#include <QBuffer>
#include <QDateTime>
#include <QFile>
#include <QImage>
#include <QImageReader>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QPainter>
#include <QRandomGenerator>
#include <QTimer>
#include <QUuid>

namespace IG {

UploadEndpoint::UploadEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {
    connect(m_client, &ApiClient::uploadProgress, this,
            [this](const QString & requestId, double percent) {
                if (requestId == m_uploadRequestId) {
                    emit uploadProgress(percent);
                }
            });
}

void UploadEndpoint::postImage(const QString & path, const QString & caption,
                               const QVariantMap & location, const QString & uploadId,
                               const QString & disableComments) {
    QByteArray jpegData;
    if (!readJpeg(path, jpegData, m_imageSize)) {
        emit error("Image not found: " + path);
        return;
    }

    m_caption = caption;
    m_location = location;
    m_disableComments = disableComments;

    const QString id =
        uploadId.isEmpty() ? QString::number(QDateTime::currentMSecsSinceEpoch()) : uploadId;
    uploadPhoto(jpegData, id, [this, id]() { configurePhoto(id); });
}

void UploadEndpoint::postVideo(const QString & videoPath, const QString & coverPath, int width,
                               int height, qint64 durationMs, const QString & caption,
                               const QVariantMap & location, const QString & disableComments) {
    QFile videoFile(videoPath);
    if (!videoFile.open(QIODevice::ReadOnly)) {
        emit error("Video not found: " + videoPath);
        return;
    }
    const QByteArray videoData = videoFile.readAll();
    videoFile.close();

    QByteArray coverData;
    QSize coverSize;
    if (!readJpeg(coverPath, coverData, coverSize)) {
        emit error("Video cover not found: " + coverPath);
        return;
    }

    m_caption = caption;
    m_disableComments = disableComments;
    m_location = location;
    m_videoSize = QSize(width, height);
    m_videoDurationMs = durationMs;

    const QString uploadId = QString::number(QDateTime::currentMSecsSinceEpoch());
    uploadVideo(videoData, uploadId, [this, coverData, uploadId]() {
        uploadPhoto(coverData, uploadId, [this, uploadId]() { configureVideo(uploadId, 1); });
    });
}

void UploadEndpoint::changeProfilePicture(const QString & photoPath) {
    QByteArray jpegData;
    QSize size;
    if (!readJpeg(photoPath, jpegData, size)) {
        emit error("Image not found: " + photoPath);
        return;
    }

    const QString uploadId = QString::number(QDateTime::currentMSecsSinceEpoch());
    uploadPhoto(jpegData, uploadId, [this, uploadId]() {
        auto request = RequestBuilder::post("accounts/change_profile_picture/")
                           .param("use_fbuploader", "true")
                           .param("upload_id", uploadId)
                           .authenticated()
                           .build();

        m_client->execute(request, [this](const Response & response) {
            if (response.ok()) {
                emit profilePictureChanged(response.toVariant());
            } else {
                emit error(response.errorMessage());
            }
        });
    });
}

bool UploadEndpoint::readJpeg(const QString & path, QByteArray & jpegData, QSize & size) {
    QImageReader reader(path);
    reader.setAutoTransform(true);
    QImage image = reader.read();
    if (image.isNull()) {
        return false;
    }

    if (image.hasAlphaChannel()) {
        QImage opaque(image.size(), QImage::Format_RGB32);
        opaque.fill(Qt::white);
        QPainter painter(&opaque);
        painter.drawImage(0, 0, image);
        painter.end();
        image = opaque;
    }

    QBuffer buffer(&jpegData);
    buffer.open(QIODevice::WriteOnly);
    if (!image.save(&buffer, "JPG", 95)) {
        return false;
    }

    size = image.size();
    return true;
}

void UploadEndpoint::uploadPhoto(const QByteArray & jpegData, const QString & uploadId,
                                 std::function<void()> onUploaded) {
    const int uploadSuffix = QRandomGenerator::global()->bounded(1000000000, 2147483647);
    const QString uploadName = QString("%1_0_%2").arg(uploadId).arg(uploadSuffix);

    QJsonObject ruploadParams;
    ruploadParams.insert("retry_context",
                         QStringLiteral("{\"num_step_auto_retry\":0,\"num_reupload\":0,"
                                        "\"num_step_manual_retry\":0}"));
    ruploadParams.insert("media_type", "1");
    ruploadParams.insert("xsharing_user_ids", "[]");
    ruploadParams.insert("upload_id", uploadId);
    ruploadParams.insert(
        "image_compression",
        QStringLiteral("{\"lib_name\":\"moz\",\"lib_version\":\"3.1.m\",\"quality\":\"80\"}"));

    QString waterfallId = QUuid::createUuid().toString();
    waterfallId = waterfallId.mid(1, waterfallId.length() - 2);

    auto request =
        RequestBuilder::post("")
            .absoluteUrl(QStringLiteral("https://i.instagram.com/rupload_igphoto/") + uploadName)
            .header("X-Instagram-Rupload-Params",
                    QJsonDocument(ruploadParams).toJson(QJsonDocument::Compact))
            .header("X_FB_PHOTO_WATERFALL_ID", waterfallId.toUtf8())
            .header("X-Entity-Type", "image/jpeg")
            .header("Offset", "0")
            .header("X-Entity-Name", uploadName.toUtf8())
            .header("X-Entity-Length", QByteArray::number(jpegData.size()))
            .octetStream(jpegData)
            .build();

    m_uploadRequestId = m_client->execute(request, [this, onUploaded](const Response & response) {
        m_uploadRequestId.clear();
        if (response.ok()) {
            onUploaded();
        } else {
            emit error(response.errorMessage());
        }
    });
}

void UploadEndpoint::uploadVideo(const QByteArray & videoData, const QString & uploadId,
                                 std::function<void()> onUploaded) {
    const int uploadSuffix = QRandomGenerator::global()->bounded(1000000000, 2147483647);
    const QString uploadName = QString("%1_0_%2").arg(uploadId).arg(uploadSuffix);
    const QString url = QStringLiteral("https://i.instagram.com/rupload_igvideo/") + uploadName;

    QJsonObject ruploadParams;
    ruploadParams.insert("retry_context",
                         QStringLiteral("{\"num_step_auto_retry\":0,\"num_reupload\":0,"
                                        "\"num_step_manual_retry\":0}"));
    ruploadParams.insert("media_type", "2");
    ruploadParams.insert("xsharing_user_ids", "[]");
    ruploadParams.insert("upload_id", uploadId);
    ruploadParams.insert("upload_media_duration_ms", QString::number(m_videoDurationMs));
    ruploadParams.insert("upload_media_width", QString::number(m_videoSize.width()));
    ruploadParams.insert("upload_media_height", QString::number(m_videoSize.height()));
    const QByteArray params = QJsonDocument(ruploadParams).toJson(QJsonDocument::Compact);

    QString waterfallId = QUuid::createUuid().toString();
    waterfallId = waterfallId.mid(1, waterfallId.length() - 2);

    auto startRequest = RequestBuilder::get("")
                            .absoluteUrl(url)
                            .header("X-Instagram-Rupload-Params", params)
                            .header("X_FB_VIDEO_WATERFALL_ID", waterfallId.toUtf8())
                            .header("X-Entity-Type", "video/mp4")
                            .build();

    m_client->execute(startRequest, [this, url, params, waterfallId, uploadName, videoData,
                                     onUploaded](const Response & startResponse) {
        if (startResponse.httpCode() != 200) {
            emit error(startResponse.errorMessage());
            return;
        }

        auto request = RequestBuilder::post("")
                           .absoluteUrl(url)
                           .header("X-Instagram-Rupload-Params", params)
                           .header("X_FB_VIDEO_WATERFALL_ID", waterfallId.toUtf8())
                           .header("X-Entity-Type", "video/mp4")
                           .header("Offset", "0")
                           .header("X-Entity-Name", uploadName.toUtf8())
                           .header("X-Entity-Length", QByteArray::number(videoData.size()))
                           .octetStream(videoData)
                           .build();

        m_uploadRequestId =
            m_client->execute(request, [this, onUploaded](const Response & response) {
                m_uploadRequestId.clear();
                if (response.httpCode() == 200) {
                    onUploaded();
                } else {
                    emit error(response.errorMessage());
                }
            });
    });
}

void UploadEndpoint::configureVideo(const QString & uploadId, int attempt) {
    const double lengthSeconds = m_videoDurationMs / 1000.0;

    QJsonObject device;
    device.insert("manufacturer", Constants::deviceManufacturer());
    device.insert("model", Constants::deviceModel());
    device.insert("android_version", Constants::androidVersion().toInt());
    device.insert("android_release", Constants::androidRelease());

    QJsonObject extra;
    extra.insert("source_width", m_videoSize.width());
    extra.insert("source_height", m_videoSize.height());

    QJsonObject clip;
    clip.insert("length", lengthSeconds);
    clip.insert("source_type", "4");
    QJsonArray clips;
    clips.append(clip);

    auto builder =
        RequestBuilder::post("media/configure/")
            .queryParam("video", "1")
            .param("upload_id", uploadId)
            .param("caption", m_caption)
            .param("source_type", "4")
            .param("multi_sharing", "1")
            .param("poster_frame_index", 0)
            .param("length", QString::number(lengthSeconds, 'f', 3))
            .param("audio_muted", false)
            .param("filter_type", "0")
            .param("timezone_offset", QString::number(Constants::timezoneOffset()))
            .param("date_time_original",
                   QDateTime::currentDateTimeUtc().toString("yyyyMMdd'T'HHmmss'.000Z'"))
            .param("clips", clips)
            .param("extra", extra)
            .param("device", device)
            .authenticated();

    addLocation(builder);

    if (m_disableComments == "1") {
        builder.param("disable_comments", "1");
    }

    m_client->execute(builder.build(), [this, uploadId, attempt](const Response & response) {
        if (response.ok()) {
            m_caption.clear();
            m_location.clear();
            emit videoConfigured(response.toVariant());
            return;
        }

        // Instagram answers until the uploaded video is transcoded
        const int maxAttempts = 30;
        if (response.errorMessage().contains("Transcode not finished") && attempt < maxAttempts) {
            QTimer::singleShot(4000, this, [this, uploadId, attempt]() {
                configureVideo(uploadId, attempt + 1);
            });
            return;
        }

        m_caption.clear();
        emit error(response.errorMessage());
    });
}

void UploadEndpoint::addLocation(RequestBuilder & builder) const {
    if (m_location.isEmpty() || m_location["name"].toString().isEmpty()) {
        return;
    }

    QJsonObject locationObj;
    QString eisk = m_location["external_id_source"].toString() + "_id";
    locationObj.insert(eisk, m_location["external_id"].toString());
    locationObj.insert("name", m_location["name"].toString());
    locationObj.insert("lat", m_location["lat"].toString());
    locationObj.insert("lng", m_location["lng"].toString());
    locationObj.insert("address", m_location["address"].toString());
    locationObj.insert("external_source", m_location["external_id_source"].toString());

    builder.param("location", QString(QJsonDocument(locationObj).toJson(QJsonDocument::Compact)))
        .param("geotag_enabled", true)
        .param("media_latitude", m_location["lat"].toString())
        .param("posting_latitude", m_location["lat"].toString())
        .param("media_longitude", m_location["lng"].toString())
        .param("posting_longitude", m_location["lng"].toString())
        .param("altitude", QString::number(QRandomGenerator::global()->bounded(800, 810)));
}

void UploadEndpoint::configurePhoto(const QString & uploadId) {
    QJsonObject device;
    device.insert("manufacturer", Constants::deviceManufacturer());
    device.insert("model", Constants::deviceModel());
    device.insert("android_version", Constants::androidVersion().toInt());
    device.insert("android_release", Constants::androidRelease());

    QJsonObject extra;
    extra.insert("source_width", m_imageSize.width());
    extra.insert("source_height", m_imageSize.height());

    QJsonArray cropOriginalSize;
    cropOriginalSize.append(static_cast<double>(m_imageSize.width()));
    cropOriginalSize.append(static_cast<double>(m_imageSize.height()));

    QJsonArray cropCenter;
    cropCenter.append(0.0);
    cropCenter.append(-0.0);

    QJsonObject edits;
    edits.insert("crop_original_size", cropOriginalSize);
    edits.insert("crop_center", cropCenter);
    edits.insert("crop_zoom", 1.0);

    const QString now = QDateTime::currentDateTimeUtc().toString("yyyyMMdd'T'HHmmss'.000Z'");

    auto builder = RequestBuilder::post("media/configure/")
                       .param("upload_id", uploadId)
                       .param("caption", m_caption)
                       .param("source_type", "4")
                       .param("media_folder", "Camera")
                       .param("scene_capture_type", "standard")
                       .param("multi_sharing", "1")
                       .param("camera_model", Constants::deviceModel())
                       .param("camera_make", Constants::deviceManufacturer())
                       .param("timezone_offset", QString::number(Constants::timezoneOffset()))
                       .param("date_time_original", now)
                       .param("date_time_digitalized", now)
                       .param("edits", edits)
                       .param("extra", extra)
                       .param("device", device)
                       .authenticated();

    addLocation(builder);

    // Add disable comments if set
    if (m_disableComments == "1") {
        builder.param("disable_comments", "1");
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        m_caption.clear();
        m_location.clear();

        if (response.ok()) {
            emit imageConfigured(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
