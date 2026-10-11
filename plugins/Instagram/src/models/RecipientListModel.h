#ifndef INSTAGRAM_RECIPIENTLISTMODEL_H
#define INSTAGRAM_RECIPIENTLISTMODEL_H

#include "JsonListModel.h"

class RecipientListModel : public JsonListModel {
    Q_OBJECT
public:
    explicit RecipientListModel(QObject * parent = nullptr);

protected:
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_RECIPIENTLISTMODEL_H
