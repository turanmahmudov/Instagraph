#ifndef INSTAGRAM_DIRECTINBOXMODEL_H
#define INSTAGRAM_DIRECTINBOXMODEL_H

#include "JsonListModel.h"

class DirectInboxModel : public JsonListModel {
    Q_OBJECT
public:
    explicit DirectInboxModel(QObject * parent = nullptr);

protected:
    // options.activeUserId: the viewer user id
    // options.typeTexts: the map from DirectTypeTexts.getDirectTypeTexts()
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_DIRECTINBOXMODEL_H
