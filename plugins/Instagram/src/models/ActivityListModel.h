#ifndef INSTAGRAM_ACTIVITYLISTMODEL_H
#define INSTAGRAM_ACTIVITYLISTMODEL_H

#include "JsonListModel.h"

class ActivityListModel : public JsonListModel {
    Q_OBJECT
public:
    explicit ActivityListModel(QObject * parent = nullptr);

protected:
    // options.friendRequests: build the follow requests row from the first item
    // options.linkColor: link color in the activity text
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_ACTIVITYLISTMODEL_H
