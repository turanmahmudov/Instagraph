#ifndef INSTAGRAM_USERLISTMODEL_H
#define INSTAGRAM_USERLISTMODEL_H

#include "JsonListModel.h"

class UserListModel : public JsonListModel {
    Q_OBJECT
public:
    explicit UserListModel(QObject * parent = nullptr);

protected:
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_USERLISTMODEL_H
