#include "MediaFeedModel.h"
#include "JsonValues.h"

using namespace JsonValues;

namespace {

const QStringList roleKeys = {
    QStringLiteral("list_type"),
    QStringLiteral("id"),
    QStringLiteral("photo_id"),
    QStringLiteral("code"),
    QStringLiteral("photo_of_you"),
    QStringLiteral("media_type"),
    QStringLiteral("has_liked"),
    QStringLiteral("like_count"),
    QStringLiteral("taken_at"),
    QStringLiteral("caption"),
    QStringLiteral("can_view_more_preview_comments"),
    QStringLiteral("has_more_comments"),
    QStringLiteral("comment_count"),
    QStringLiteral("comments_disabled"),
    QStringLiteral("has_viewer_saved"),
    QStringLiteral("location"),
    QStringLiteral("user"),
    QStringLiteral("preview_comments"),
    QStringLiteral("carousel_media_obj"),
    QStringLiteral("images_obj"),
    QStringLiteral("video_url"),
    QStringLiteral("preview_candidates"),
    QStringLiteral("image_versions2"),
    QStringLiteral("video_duration"),
};

QJsonObject buildEmptyCaption() {
    return QJsonObject{{"text", ""}, {"user", QJsonObject{{"username", ""}}}};
}

void insertPreviewCandidates(QJsonObject & entry) {
    const QJsonArray carousel =
        entry.value("carousel_media_obj").toObject().value("media").toArray();
    entry.insert("preview_candidates",
                 !carousel.isEmpty()
                     ? carousel.at(0).toObject().value("image_versions2").toObject().value(
                           "candidates")
                     : entry.value("images_obj").toObject().value("candidates"));
}

void insertMediaFiles(QJsonObject & entry, const QJsonObject & media) {
    entry.insert("carousel_media_obj",
                 QJsonObject{{"media", media.contains("carousel_media")
                                           ? media.value("carousel_media")
                                           : QJsonValue(QJsonArray())}});
    entry.insert("images_obj", media.contains("image_versions2") ? media.value("image_versions2")
                                                                  : QJsonValue(QJsonObject()));
    entry.insert("video_url",
                 media.contains("video_versions")
                     ? media.value("video_versions").toArray().at(0).toObject().value("url")
                     : QJsonValue(QString()));
    entry.insert("list_type", "media_entry");
    insertPreviewCandidates(entry);
}

QVariantMap buildSavedMediaEntry(const QJsonObject & media) {
    QJsonObject entry;
    entry.insert("id", media.value("id"));
    entry.insert("photo_id", media.value("id"));
    entry.insert("code", media.value("code"));
    entry.insert("photo_of_you", media.value("photo_of_you"));
    entry.insert("media_type", media.value("media_type"));
    entry.insert("has_liked", media.value("has_liked"));
    if (!media.value("like_count").isUndefined()) {
        entry.insert("like_count", formatLocaleNumber(media.value("like_count")));
    }
    entry.insert("taken_at", media.value("taken_at"));
    entry.insert("caption", pickTruthy(media.value("caption"), buildEmptyCaption()));
    entry.insert("has_more_comments", media.value("has_more_comments"));
    entry.insert("comment_count", media.value("comment_count"));
    entry.insert("comments_disabled", media.value("comments_disabled"));
    entry.insert("has_viewer_saved", isTrue(media.value("has_viewer_saved")));
    entry.insert("user", media.value("user"));

    QJsonObject previewComments;
    if (media.value("preview_comments").isArray()) {
        QJsonArray comments = media.value("preview_comments").toArray();
        int visibleCount = media.value("max_num_visible_preview_comments").toInt();
        for (int j = 0; j < visibleCount && j < comments.size(); ++j) {
            QJsonObject comment = comments.at(j).toObject();
            comment.insert("ctext", comment.value("text"));
            comments.replace(j, comment);
        }
        previewComments.insert("comments", comments);
    } else {
        previewComments.insert("comments", media.value("preview_comments"));
    }
    entry.insert("preview_comments", previewComments);

    insertMediaFiles(entry, media);
    return convertObjectWithoutNulls(entry);
}

QVariantMap buildMediaEntry(const QJsonObject & media) {
    QJsonObject entry;
    for (const QString & key : roleKeys) {
        if (media.contains(key)) {
            entry.insert(key, media.value(key));
        }
    }
    entry.insert("photo_id", media.value("id"));
    entry.insert("caption", pickTruthy(media.value("caption"), buildEmptyCaption()));
    entry.insert("comments_disabled", isTrue(media.value("comments_disabled")));
    entry.insert("photo_of_you", isTrue(media.value("photo_of_you")));
    entry.insert("has_viewer_saved", isTrue(media.value("has_viewer_saved")));

    QJsonArray comments;
    for (const QJsonValue & value : pickTruthy(media.value("preview_comments"), QJsonArray())
                                        .toArray()) {
        QJsonObject comment = value.toObject();
        comment.insert("ctext", comment.value("text"));
        comments.append(comment);
    }
    entry.insert("preview_comments", QJsonObject{{"comments", comments}});

    insertMediaFiles(entry, media);
    return convertObjectWithoutNulls(entry);
}

QJsonArray extractSectionMedia(const QJsonArray & sections) {
    QJsonArray medias;
    for (const QJsonValue & value : sections) {
        const QJsonObject section = value.toObject();
        const QString layoutType = section.value("layout_type").toString();
        if (layoutType != "media_grid" && layoutType != "one_by_two" &&
            layoutType != "two_by_two") {
            continue;
        }

        const QJsonValue content = section.value("layout_content");
        const QJsonValue sectionMedias = content.toObject().value("medias");
        if (!isTruthy(content) || !isTruthy(sectionMedias)) {
            continue;
        }

        for (const QJsonValue & media : sectionMedias.toArray()) {
            if (isTruthy(media) && isTruthy(media.toObject().value("media"))) {
                medias.append(media.toObject().value("media"));
            }
        }
    }
    return medias;
}

} // namespace

MediaFeedModel::MediaFeedModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

int MediaFeedModel::countSectionMedia(const QString & path) const {
    return extractSectionMedia(findParsedItems(path)).size();
}

QVariant MediaFeedModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                  const QVariantMap & options, bool clear,
                                  QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(clear)

    bool savedMedia = options.value("savedMedia").toBool();
    const QJsonArray medias =
        options.value("sections").toBool() ? extractSectionMedia(items) : items;
    rows.reserve(medias.size());
    for (const QJsonValue & item : medias) {
        if (savedMedia) {
            rows.append(buildSavedMediaEntry(item.toObject().value("media").toObject()));
        } else {
            rows.append(buildMediaEntry(item.toObject()));
        }
    }
    return QVariant();
}
