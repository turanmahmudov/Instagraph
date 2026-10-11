#include "DirectInboxModel.h"
#include "JsonValues.h"

using namespace JsonValues;

namespace {

const QStringList roleKeys = {
    QStringLiteral("thread_id"),   QStringLiteral("thread_title"),
    QStringLiteral("thread_text"), QStringLiteral("thread_time"),
    QStringLiteral("unseen"),      QStringLiteral("profile_pic_url"),
};

bool isThreadUnread(const QJsonObject & thread, const QString & viewerId) {
    const QJsonValue itemValue = thread.value("last_permanent_item");
    const QJsonObject item = itemValue.toObject();
    if (!isTruthy(itemValue) || convertToString(item.value("user_id")) == viewerId) {
        return false;
    }

    const QJsonValue seen =
        pickTruthy(thread.value("last_seen_at"), QJsonObject()).toObject().value(viewerId);
    if (!isTruthy(seen)) {
        return true;
    }
    return convertToNumber(item.value("timestamp")) >
           convertToNumber(seen.toObject().value("timestamp"));
}

QJsonValue buildThreadText(const QJsonValue & itemValue, const QString & activeUserId,
                           const QVariantMap & typeTexts) {
    if (!isTruthy(itemValue)) {
        return QString();
    }

    const QJsonObject item = itemValue.toObject();
    const QString itemType = item.value("item_type").toString();
    bool fromViewer = convertToString(item.value("user_id")) == activeUserId;
    auto pickText = [&](const char * viewerKey, const char * otherKey) {
        return QJsonValue::fromVariant(typeTexts.value(fromViewer ? viewerKey : otherKey));
    };

    if (itemType == "media_share") {
        return pickText("you_shared_a_post", "shared_a_post");
    }
    if (itemType == "media") {
        return pickText("you_shared_a_media", "shared_a_media");
    }
    if (itemType == "story_share") {
        return pickText("you_sent_a_story", "sent_a_story");
    }
    if (itemType == "link") {
        return pickText("you_shared_a_link", "shared_a_link");
    }
    if (itemType == "like") {
        return item.value("like");
    }
    if (itemType == "action_log") {
        return item.value("action_log").toObject().value("description");
    }
    if (itemType == "placeholder") {
        return item.value("placeholder").toObject().value("title");
    }
    if (itemType == "reel_share") {
        const QString reelType = item.value("reel_share").toObject().value("type").toString();
        if (reelType == "mention") {
            return pickText("you_mentioned_them_in_a_story", "mentioned_you_in_a_story");
        }
        if (reelType == "reply") {
            return pickText("you_replied_to_their_story", "replied_to_your_story");
        }
        return QJsonValue::fromVariant(typeTexts.value("unknown"));
    }
    if (itemType == "store_sticker") {
        return pickText("you_sent_a_sticker", "sent_a_sticker");
    }
    if (itemType.contains("xma")) {
        return pickText("you_shared_a_post", "shared_a_post");
    }
    return pickTruthy(item.value("text"), "");
}

} // namespace

DirectInboxModel::DirectInboxModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant DirectInboxModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                    const QVariantMap & options, bool clear,
                                    QVector<QVariantMap> & rows) {
    Q_UNUSED(response)
    Q_UNUSED(clear)

    const QString activeUserId = options.value("activeUserId").toString();
    const QVariantMap typeTexts = options.value("typeTexts").toMap();

    rows.reserve(items.size());
    for (const QJsonValue & value : items) {
        const QJsonObject thread = value.toObject();
        const QJsonObject inviter = thread.value("inviter").toObject();
        const QJsonArray users = thread.value("users").toArray();
        const QJsonValue lastItem = thread.value("last_permanent_item");
        const QJsonValue title = thread.value("thread_title");

        QJsonObject entry;
        entry.insert("thread_id", thread.value("thread_id"));
        entry.insert("thread_title", title.isString() && title.toString().isEmpty()
                                         ? inviter.value("username")
                                         : title);
        entry.insert("thread_text", buildThreadText(lastItem, activeUserId, typeTexts));
        entry.insert("thread_time", lastItem.toObject().value("timestamp"));
        entry.insert("unseen", isThreadUnread(thread, activeUserId));
        entry.insert("profile_pic_url", !users.isEmpty()
                                            ? users.at(0).toObject().value("profile_pic_url")
                                            : inviter.value("profile_pic_url"));
        rows.append(entry.toVariantMap());
    }
    return QVariant();
}
