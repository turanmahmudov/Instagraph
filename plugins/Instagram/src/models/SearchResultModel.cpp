#include "SearchResultModel.h"

namespace {

const QStringList roleKeys = {
    QStringLiteral("search_type"), QStringLiteral("user"),
    QStringLiteral("pk"),          QStringLiteral("user_id"),
    QStringLiteral("name"),        QStringLiteral("keyword"),
    QStringLiteral("media_count"), QStringLiteral("title"),
    QStringLiteral("subtitle"),    QStringLiteral("location"),
    QStringLiteral("address"),     QStringLiteral("lat"),
    QStringLiteral("lng"),         QStringLiteral("external_id"),
    QStringLiteral("external_id_source"),
};

} // namespace

SearchResultModel::SearchResultModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant SearchResultModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                     const QVariantMap & options, bool clear,
                                     QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(clear)

    const QString type = options.value("type").toString();
    for (const QJsonValue & value : items) {
        QJsonObject result = value.toObject();

        if (type == "recentSearches") {
            if (result.contains("user")) {
                QJsonValue pk = result.value("user").toObject().value("pk");
                result.insert("search_type", "user");
                result.insert("pk", pk);
                result.insert("user_id", pk);
                rows.append(result.toVariantMap());
            } else if (result.contains("keyword")) {
                result.insert("search_type", "keyword");
                result.insert("name", result.value("keyword").toObject().value("name"));
                rows.append(result.toVariantMap());
            }
        } else if (type == "searchUsers") {
            QJsonObject entry;
            entry.insert("user", QJsonObject{
                                     {"pk", result.value("pk")},
                                     {"username", result.value("username")},
                                     {"full_name", result.value("full_name")},
                                     {"profile_pic_url", result.value("profile_pic_url")},
                                 });
            entry.insert("pk", result.value("pk"));
            entry.insert("user_id", result.value("pk"));
            rows.append(entry.toVariantMap());
        } else if (type == "searchTags" || type == "searchVenues") {
            rows.append(result.toVariantMap());
        } else if (type == "searchLocation") {
            result.insert("pk", result.value("location").toObject().value("pk"));
            rows.append(result.toVariantMap());
        }
    }
    return QVariant();
}
