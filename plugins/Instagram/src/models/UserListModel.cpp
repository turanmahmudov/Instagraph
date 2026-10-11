#include "UserListModel.h"

namespace {

const QStringList roleKeys = {QStringLiteral("user")};

} // namespace

UserListModel::UserListModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant UserListModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                 const QVariantMap & options, bool clear,
                                 QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(options)
    Q_UNUSED(clear)

    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        rows.append(QVariantMap{{"user", value.toVariant()}});
    }
    return QVariant();
}
