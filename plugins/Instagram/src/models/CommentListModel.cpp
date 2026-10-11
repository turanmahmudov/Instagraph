#include "CommentListModel.h"
#include "JsonValues.h"

using namespace JsonValues;

namespace {

const QStringList roleKeys = {
    QStringLiteral("is_caption"), QStringLiteral("pk"),         QStringLiteral("comment_text"),
    QStringLiteral("has_liked"),  QStringLiteral("like_count"), QStringLiteral("user"),
    QStringLiteral("created_at"),
};

} // namespace

CommentListModel::CommentListModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant CommentListModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                    const QVariantMap & options, bool clear,
                                    QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(clear)

    bool isCaption = options.value("isCaption").toBool();
    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        const QJsonObject comment = value.toObject();
        QJsonObject entry;
        entry.insert("is_caption", isCaption);
        entry.insert("pk", comment.value("pk"));
        entry.insert("comment_text", pickTruthy(comment.value("text"), ""));
        entry.insert("has_liked", isTrue(comment.value("has_liked_comment")));
        entry.insert("like_count", pickTruthy(comment.value("comment_like_count"), 0));
        entry.insert("user", comment.value("user"));
        entry.insert("created_at", comment.value("created_at"));
        rows.append(entry.toVariantMap());
    }
    return QVariant();
}
