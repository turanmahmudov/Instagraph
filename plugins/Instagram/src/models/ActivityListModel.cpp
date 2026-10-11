#include "ActivityListModel.h"
#include "JsonValues.h"

using namespace JsonValues;

namespace {

const QStringList roleKeys = {
    QStringLiteral("list_type"),     QStringLiteral("request_count"),
    QStringLiteral("profile_pic_url"), QStringLiteral("header"),
    QStringLiteral("activity_text"), QStringLiteral("story_type"),
    QStringLiteral("profile_image"), QStringLiteral("profile_id"),
    QStringLiteral("media"),         QStringLiteral("inline_follow"),
    QStringLiteral("timestamp"),
};

QString buildLink(const QString & link, const QString & value, const QString & linkColor) {
    return QStringLiteral("<a href=\"") + link +
           QStringLiteral("\" style=\"text-decoration:none;font-weight:500;color:") + linkColor +
           QStringLiteral(";\">") + (value.isEmpty() ? link : value) + QStringLiteral("</a>");
}

QString replaceFirst(const QString & text, const QString & part, const QString & replacement) {
    int index = text.indexOf(part);
    if (index < 0) {
        return text;
    }
    QString replaced = text;
    return replaced.replace(index, part.size(), replacement);
}

QJsonValue buildActivityText(const QJsonObject & args, const QString & linkColor) {
    if (args.isEmpty()) {
        return QString();
    }

    if (!args.contains("links")) {
        if (args.contains("rich_text")) {
            return pickTruthy(args.value("rich_text"), "");
        }
        return pickTruthy(args.value("text"), "");
    }

    const QJsonArray links = args.value("links").toArray();
    if (links.isEmpty()) {
        return QString();
    }

    QString activityText = args.value("text").toString();
    QStringList parts;
    for (const QJsonValue & value : links) {
        const QJsonObject link = value.toObject();
        int start = link.value("start").toInt();
        int end = link.value("end").toInt();
        parts.append(activityText.mid(start, end - start));
    }

    for (int j = 0; j < parts.size(); ++j) {
        const QJsonObject link = links.at(j).toObject();
        const QString type = link.value("type").toString();
        const QString & part = parts.at(j);
        if (type == "like_count_chrono") {
            activityText = replaceFirst(activityText, part,
                                        buildLink(QStringLiteral("likes://") + part, part,
                                                  linkColor));
        } else if (type == "user") {
            activityText = replaceFirst(
                activityText, part,
                buildLink(QStringLiteral("userid://") + convertToString(link.value("id")), part,
                          linkColor));
        }
    }

    return activityText;
}

QJsonValue findHeader(const QJsonObject & partition, int index) {
    if (partition.isEmpty() || !partition.contains("time_bucket")) {
        return QJsonValue(QJsonValue::Undefined);
    }

    const QJsonObject timeBucket = partition.value("time_bucket").toObject();
    const QJsonArray headers = timeBucket.value("headers").toArray();
    const QJsonArray indices = timeBucket.value("indices").toArray();
    for (int j = 0; j < headers.size(); ++j) {
        if (indices.at(j).isDouble() && indices.at(j).toDouble() == index) {
            return headers.at(j);
        }
    }
    return QJsonValue(QJsonValue::Undefined);
}

} // namespace

ActivityListModel::ActivityListModel(QObject * parent) : JsonListModel(roleKeys, parent) {}

QVariant ActivityListModel::mapItems(const QJsonArray & items, const QJsonObject & response,
                                     const QVariantMap & options, bool clear,
                                     QVector<QVariantMap> & rows) {
    Q_UNUSED(clear)

    if (options.value("friendRequests").toBool()) {
        const QJsonObject args = items.at(0).toObject().value("args").toObject();
        QJsonObject entry;
        entry.insert("list_type", "follow_requests");
        entry.insert("request_count", args.value("request_count"));
        entry.insert("profile_pic_url", args.value("profile_image"));
        rows.append(entry.toVariantMap());
        return QVariant();
    }

    const QString linkColor = options.value("linkColor").toString();
    const QJsonObject partition = response.value("partition").toObject();

    for (int i = 0; i < items.size(); ++i) {
        const QJsonObject item = items.at(i).toObject();
        const QJsonObject args = item.value("args").toObject();
        const QJsonArray media = args.value("media").toArray();

        QJsonObject entry;
        entry.insert("list_type", "recent_activity");
        entry.insert("header", pickTruthy(findHeader(partition, i), ""));
        entry.insert("activity_text", buildActivityText(args, linkColor));
        entry.insert("story_type", item.value("type"));
        entry.insert("profile_image",
                     args.contains("profile_image") ? args.value("profile_image") : "");
        entry.insert("profile_id", args.contains("profile_id") ? args.value("profile_id") : "");
        entry.insert("media", args.contains("media") && !media.isEmpty()
                                  ? media.at(0)
                                  : QJsonValue(QJsonObject{{"image", ""}, {"id", ""}}));
        if (args.contains("inline_follow")) {
            entry.insert("inline_follow", args.value("inline_follow"));
        }
        entry.insert("timestamp", pickTruthy(args.value("timestamp"), 0));
        rows.append(entry.toVariantMap());
    }

    return QVariant();
}
