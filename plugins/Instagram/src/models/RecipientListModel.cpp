#include "RecipientListModel.h"
#include "JsonValues.h"

namespace {

const QStringList roleKeys = {QStringLiteral("user_obj")};

} // namespace

RecipientListModel::RecipientListModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant RecipientListModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                      const QVariantMap & options, bool clear,
                                      QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(options)
    Q_UNUSED(clear)

    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        const QJsonObject recipient = value.toObject();
        QJsonObject entry;
        entry.insert("user_obj", recipient.contains("user") ? recipient.value("user")
                                                            : recipient.value("thread")
                                                                  .toObject()
                                                                  .value("users")
                                                                  .toArray()
                                                                  .at(0));
        rows.append(JsonValues::convertObjectWithoutNulls(entry));
    }
    return QVariant();
}
