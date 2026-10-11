#ifndef INSTAGRAM_DIRECTTHREADMODEL_H
#define INSTAGRAM_DIRECTTHREADMODEL_H

#include "JsonListModel.h"

class DirectThreadModel : public JsonListModel {
    Q_OBJECT
public:
    explicit DirectThreadModel(QObject * parent = nullptr);

    Q_INVOKABLE void insertItem(const QVariantMap & item);

protected:
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_DIRECTTHREADMODEL_H
