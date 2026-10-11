#include "TimelineFeedModel.h"
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
    QStringLiteral("comment_count"),
    QStringLiteral("comments_disabled"),
    QStringLiteral("has_viewer_saved"),
    QStringLiteral("location"),
    QStringLiteral("user"),
    QStringLiteral("preview_comments"),
    QStringLiteral("carousel_media_obj"),
    QStringLiteral("images_obj"),
    QStringLiteral("video_url"),
    QStringLiteral("title"),
    QStringLiteral("subtitle"),
};

QJsonObject buildEmptyCaption() {
    return QJsonObject{{"text", ""}, {"user", QJsonObject{{"username", ""}}}};
}

QJsonObject buildPreviewComments(const QJsonObject & media) {
    QJsonArray comments;
    if (isTruthy(media.value("preview_comments"))) {
        for (const QJsonValue & value : media.value("preview_comments").toArray()) {
            QJsonObject comment = value.toObject();
            comment.insert("ctext", comment.value("text"));
            comments.append(comment);
        }
    }
    return QJsonObject{{"comments", comments}};
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
}

QVariantMap buildMediaEntry(const QJsonObject & media) {
    QJsonObject entry;
    entry.insert("id", media.value("id"));
    entry.insert("photo_id", media.value("id"));
    entry.insert("code", media.value("code"));
    entry.insert("photo_of_you", isTrue(media.value("photo_of_you")));
    entry.insert("media_type", media.value("media_type"));
    entry.insert("has_liked", media.value("has_liked"));
    if (!media.value("like_count").isUndefined()) {
        entry.insert("like_count", formatLocaleNumber(media.value("like_count")));
    }
    entry.insert("taken_at", media.value("taken_at"));
    entry.insert("caption", pickTruthy(media.value("caption"), buildEmptyCaption()));
    entry.insert("can_view_more_preview_comments", media.value("can_view_more_preview_comments"));
    entry.insert("comment_count", media.value("comment_count"));
    entry.insert("comments_disabled", isTrue(media.value("comments_disabled")));
    entry.insert("has_viewer_saved", isTrue(media.value("has_viewer_saved")));
    entry.insert("location", pickTruthy(media.value("location"), QJsonObject{{"name", ""}}));
    entry.insert("user", media.value("user"));
    entry.insert("preview_comments", buildPreviewComments(media));
    insertMediaFiles(entry, media);
    entry.insert("list_type", "media_entry");
    return convertObjectWithoutNulls(entry);
}

QVariantMap buildSuggestedMediaEntry(const QJsonObject & media) {
    QJsonObject entry;
    entry.insert("id", media.value("id"));
    entry.insert("photo_id", media.value("id"));
    entry.insert("code", media.value("code"));
    entry.insert("photo_of_you", pickTruthy(media.value("photo_of_you"), false));
    entry.insert("media_type", media.value("media_type"));
    entry.insert("has_liked", pickTruthy(media.value("has_liked"), false));
    entry.insert("like_count", isTruthy(media.value("like_count"))
                                   ? formatLocaleNumber(media.value("like_count"))
                                   : QStringLiteral("0"));
    entry.insert("taken_at", media.value("taken_at"));
    entry.insert("caption", pickTruthy(media.value("caption"), buildEmptyCaption()));
    entry.insert("can_view_more_preview_comments",
                 pickTruthy(media.value("can_view_more_preview_comments"), false));
    entry.insert("comment_count", pickTruthy(media.value("comment_count"), 0));
    entry.insert("comments_disabled", pickTruthy(media.value("comments_disabled"), false));
    entry.insert("has_viewer_saved", isTrue(media.value("has_viewer_saved")));
    entry.insert("location", pickTruthy(media.value("location"), QJsonObject{{"name", ""}}));
    entry.insert("user", media.value("user"));
    entry.insert("preview_comments", buildPreviewComments(media));
    insertMediaFiles(entry, media);
    entry.insert("list_type", "media_entry");
    return convertObjectWithoutNulls(entry);
}

} // namespace

TimelineFeedModel::TimelineFeedModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

JsonListModel * TimelineFeedModel::findSuggestionsModel() const {
    return m_suggestionsModel;
}

void TimelineFeedModel::setSuggestionsModel(JsonListModel * model) {
    if (m_suggestionsModel == model) {
        return;
    }
    m_suggestionsModel = model;
    emit suggestionsModelChanged();
}

QVariant TimelineFeedModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                     const QVariantMap & options, bool clear,
                                     QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(options)

    QVariantList seenPosts;
    QVariantList endOfFeed;

    for (int i = 0; i < items.size(); ++i) {
        const QJsonObject feedItem = items.at(i).toObject();

        if (clear && i == 0) {
            rows.append(QVariantMap{{"list_type", "stories_feed"}});
        }

        if (feedItem.contains("suggested_users") &&
            feedItem.value("suggested_users").toObject().contains("suggestions")) {
            const QJsonArray suggestions =
                feedItem.value("suggested_users").toObject().value("suggestions").toArray();
            if (m_suggestionsModel) {
                for (const QJsonValue & suggestion : suggestions) {
                    m_suggestionsModel->append(convertObjectWithoutNulls(suggestion.toObject()));
                }
            }
            rows.append(QVariantMap{{"list_type", "suggested_users"}});
        } else if (feedItem.contains("media_or_ad") &&
                   !feedItem.value("media_or_ad").toObject().contains("injected")) {
            const QJsonObject media = feedItem.value("media_or_ad").toObject();
            rows.append(buildMediaEntry(media));
            seenPosts.append(media.value("id").toVariant());
        } else if (feedItem.contains("end_of_feed_demarcator")) {
            const QJsonObject demarcator = feedItem.value("end_of_feed_demarcator").toObject();
            const QJsonArray groups =
                demarcator.value("group_set").toObject().value("groups").toArray();

            if (!groups.isEmpty()) {
                const QJsonArray groupItems = groups.at(0).toObject().value("feed_items").toArray();
                if (!groupItems.isEmpty()) {
                    rows.append(QVariantMap{
                        {"list_type", "suggested_posts_header"},
                        {"title", pickTruthy(demarcator.value("title"), "Suggested for you")
                                      .toVariant()},
                        {"subtitle", pickTruthy(demarcator.value("subtitle"), "").toVariant()},
                    });

                    for (const QJsonValue & value : groupItems) {
                        const QJsonObject suggestedItem = value.toObject();
                        const QJsonObject exploreStory =
                            suggestedItem.value("explore_story").toObject();
                        if (suggestedItem.contains("explore_story") &&
                            exploreStory.contains("media_or_ad")) {
                            const QJsonObject media = exploreStory.value("media_or_ad").toObject();
                            rows.append(buildSuggestedMediaEntry(media));
                            seenPosts.append(media.value("id").toVariant());
                        }
                    }
                }
            }

            endOfFeed.append(QVariantMap{
                {"title", pickTruthy(demarcator.value("title"), "").toVariant()},
                {"subtitle", pickTruthy(demarcator.value("subtitle"), "").toVariant()},
                {"pause", pickTruthy(demarcator.value("pause"), false).toVariant()},
                {"style", pickTruthy(demarcator.value("style"), "").toVariant()},
            });
        }
    }

    return QVariantMap{{"seenPosts", seenPosts}, {"endOfFeed", endOfFeed}};
}
