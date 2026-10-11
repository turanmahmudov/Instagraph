#include "DirectThreadModel.h"
#include "JsonValues.h"

namespace {

const QStringList roleKeys = {
    QStringLiteral("item_type"),       QStringLiteral("user_id"),
    QStringLiteral("item_id"),         QStringLiteral("cText"),
    QStringLiteral("options"),         QStringLiteral("media"),
    QStringLiteral("animated_media"),  QStringLiteral("link"),
    QStringLiteral("placeholder"),     QStringLiteral("media_share"),
    QStringLiteral("reel_share"),      QStringLiteral("story_share"),
    QStringLiteral("xma_media_share"),
};

QJsonObject buildAnimatedMedia(bool isSticker, const QJsonValue & url, const QJsonValue & width,
                               const QJsonValue & height) {
    return QJsonObject{
        {"is_sticker", isSticker}, {"url", url}, {"width", width}, {"height", height}};
}

QVariantMap buildItem(const QJsonObject & item) {
    const QString itemType = item.value("item_type").toString();

    QJsonObject entry;
    entry.insert("item_type", item.value("item_type"));
    entry.insert("user_id", item.value("user_id"));
    entry.insert("item_id", item.value("item_id"));
    entry.insert("cText", item.value("text"));

    QJsonObject options;
    entry.insert("media", QJsonObject());
    entry.insert("animated_media", QJsonObject());
    entry.insert("link", QJsonObject());
    entry.insert("placeholder", QJsonObject());
    entry.insert("media_share", QJsonObject());
    entry.insert("reel_share", QJsonObject());
    entry.insert("story_share", QJsonObject());
    entry.insert("xma_media_share", QJsonObject());

    if (itemType == "animated_media") {
        const QJsonObject animatedMedia = item.value("animated_media").toObject();
        const QJsonObject fixedHeight =
            animatedMedia.value("images").toObject().value("fixed_height").toObject();
        entry.insert("animated_media",
                     buildAnimatedMedia(animatedMedia.value("is_sticker").toBool(),
                                        JsonValues::pickTruthy(fixedHeight.value("url"), ""),
                                        JsonValues::pickTruthy(fixedHeight.value("width"), "0"),
                                        JsonValues::pickTruthy(fixedHeight.value("height"), "0")));
    } else if (itemType == "raven_media") {
        const QJsonObject visualMedia = item.value("visual_media").toObject();
        options.insert("raven_media_expired",
                       !visualMedia.value("media").toObject().contains("image_versions2"));
        entry.insert("media", item.value("visual_media"));
    } else if (itemType == "link" || itemType == "placeholder" || itemType == "media" ||
               itemType == "media_share" || itemType == "reel_share" ||
               itemType == "story_share") {
        entry.insert(itemType, item.value(itemType));
    } else if (itemType == "store_sticker") {
        const QJsonObject sticker = item.value("store_sticker").toObject();
        entry.insert("item_type", "animated_media");
        entry.insert("animated_media",
                     buildAnimatedMedia(true,
                                        JsonValues::pickTruthy(sticker.value("image_url"), ""),
                                        JsonValues::convertToString(JsonValues::pickTruthy(
                                            sticker.value("image_width"), 0)),
                                        JsonValues::convertToString(JsonValues::pickTruthy(
                                            sticker.value("image_height"), 0))));
    } else {
        const QJsonArray xma = item.value(itemType).toArray();
        if (itemType.contains("xma") && !xma.isEmpty()) {
            entry.insert("item_type", "xma_media_share");
            entry.insert("xma_media_share", xma.at(0));
        }
    }

    entry.insert("options", options);
    return entry.toVariantMap();
}

} // namespace

DirectThreadModel::DirectThreadModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

void DirectThreadModel::insertItem(const QVariantMap & item) {
    insertMappedRows(0, {buildItem(QJsonObject::fromVariantMap(item))});
}

QVariant DirectThreadModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                     const QVariantMap & options, bool clear,
                                     QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(options)
    Q_UNUSED(clear)

    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        rows.append(buildItem(value.toObject()));
    }
    return QVariant();
}
