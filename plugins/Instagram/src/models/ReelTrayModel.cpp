#include "ReelTrayModel.h"
#include "JsonValues.h"

namespace {

const QStringList roleKeys = {
    QStringLiteral("id"),    QStringLiteral("user"),        QStringLiteral("seen"),
    QStringLiteral("title"), QStringLiteral("cover_media"),
};

} // namespace

ReelTrayModel::ReelTrayModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant ReelTrayModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                 const QVariantMap & options, bool clear,
                                 QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(clear)

    bool stringIds = options.value("stringIds").toBool();
    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        QJsonObject reel = value.toObject();
        if (stringIds) {
            reel.insert("id", JsonValues::convertToString(reel.value("id")));
        }
        rows.append(JsonValues::convertObjectWithoutNulls(reel));
    }
    return QVariant();
}
