#include "ExploreGridModel.h"

namespace {

const QStringList roleKeys = {
    QStringLiteral("photo_id"),   QStringLiteral("carousel_media_obj"),
    QStringLiteral("preview_candidates"),
    QStringLiteral("images_obj"), QStringLiteral("video_url"),
    QStringLiteral("media_type"), QStringLiteral("list_type"),
    QStringLiteral("rowSpan"),    QStringLiteral("columnSpan"),
    QStringLiteral("row"),        QStringLiteral("column"),
};

void insertPreviewCandidates(QJsonObject & entry) {
    const QJsonArray carousel =
        entry.value("carousel_media_obj").toObject().value("media").toArray();
    entry.insert("preview_candidates",
                 !carousel.isEmpty()
                     ? carousel.at(0).toObject().value("image_versions2").toObject().value(
                           "candidates")
                     : entry.value("images_obj").toObject().value("candidates"));
}

QJsonObject buildMedia(const QJsonObject & media) {
    QJsonObject entry;
    entry.insert("photo_id", media.value("id"));
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
    entry.insert("media_type", media.value("media_type"));
    entry.insert("list_type", "media_entry");
    insertPreviewCandidates(entry);
    return entry;
}

QJsonObject buildTwoByTwoMedia(const QJsonObject & item) {
    if (item.contains("channel")) {
        return buildMedia(item.value("channel").toObject().value("media").toObject());
    }
    if (item.contains("igtv")) {
        return buildMedia(item.value("igtv").toObject().value("media").toObject());
    }
    return buildMedia(item.value("media").toObject());
}

bool findOneByTwoMedia(const QJsonValue & value, QJsonObject & entry) {
    const QJsonObject item = value.toObject();
    if (value.isNull() || value.isUndefined() || (value.isBool() && !value.toBool())) {
        return false;
    }

    const QJsonArray clips = item.value("clips").toObject().value("items").toArray();
    if (item.contains("clips") && !clips.isEmpty()) {
        entry = buildMedia(clips.at(0).toObject().value("media").toObject());
        return true;
    }

    if (item.contains("media")) {
        entry = buildMedia(item.value("media").toObject());
        return true;
    }

    return false;
}

QJsonObject buildFillMedia(const QJsonArray & fillItems, int index) {
    return buildMedia(fillItems.at(index).toObject().value("media").toObject());
}

QVariantMap placeCell(QJsonObject entry, int rowSpan, int columnSpan, int row, int column) {
    entry.insert("rowSpan", rowSpan);
    entry.insert("columnSpan", columnSpan);
    entry.insert("row", row);
    entry.insert("column", column);
    return entry.toVariantMap();
}

} // namespace

ExploreGridModel::ExploreGridModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant ExploreGridModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                    const QVariantMap & options, bool clear,
                                    QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(options)

    if (clear) {
        m_lastRow = 0;
    }

    for (const QJsonValue & value : items) {
        const QJsonObject section = value.toObject();
        const QString layoutType = section.value("layout_type").toString();
        const QJsonObject content = section.value("layout_content").toObject();
        const QJsonArray fillItems = content.value("fill_items").toArray();

        if (layoutType == "two_by_two_right") {
            for (int j = 0; j < fillItems.size(); ++j) {
                rows.append(placeCell(buildFillMedia(fillItems, j), 1, 1, m_lastRow + j, 0));
            }
            rows.append(placeCell(buildTwoByTwoMedia(content.value("two_by_two_item").toObject()),
                                  2, 2, m_lastRow, 1));
            m_lastRow += 2;
        } else if (layoutType == "two_by_two_left") {
            rows.append(placeCell(buildTwoByTwoMedia(content.value("two_by_two_item").toObject()),
                                  2, 2, m_lastRow, 0));
            for (int j = 0; j < fillItems.size(); ++j) {
                rows.append(placeCell(buildFillMedia(fillItems, j), 1, 1, m_lastRow + j, 2));
            }
            m_lastRow += 2;
        } else if (layoutType == "one_by_two_right") {
            for (int j = 0; j < fillItems.size() && j < 4; ++j) {
                rows.append(
                    placeCell(buildFillMedia(fillItems, j), 1, 1, m_lastRow + j / 2, j % 2));
            }
            QJsonObject hero;
            if (findOneByTwoMedia(content.value("one_by_two_item"), hero)) {
                rows.append(placeCell(hero, 2, 1, m_lastRow, 2));
            }
            m_lastRow += 2;
        } else if (layoutType == "one_by_two_left") {
            QJsonObject hero;
            if (findOneByTwoMedia(content.value("one_by_two_item"), hero)) {
                rows.append(placeCell(hero, 2, 1, m_lastRow, 0));
            }
            for (int j = 0; j < fillItems.size() && j < 4; ++j) {
                rows.append(
                    placeCell(buildFillMedia(fillItems, j), 1, 1, m_lastRow + j / 2, 1 + j % 2));
            }
            m_lastRow += 2;
        } else if (layoutType == "media_grid") {
            const QJsonArray medias = content.value("medias").toArray();
            for (int j = 0; j < medias.size(); ++j) {
                rows.append(placeCell(buildFillMedia(medias, j), 1, 1, m_lastRow, j));
            }
            m_lastRow += 1;
        }
    }

    return QVariant();
}
