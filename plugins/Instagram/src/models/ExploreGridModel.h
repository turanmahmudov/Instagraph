#ifndef INSTAGRAM_EXPLOREGRIDMODEL_H
#define INSTAGRAM_EXPLOREGRIDMODEL_H

#include "JsonListModel.h"

class ExploreGridModel : public JsonListModel {
    Q_OBJECT
public:
    explicit ExploreGridModel(QObject * parent = nullptr);

protected:
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;

private:
    int m_lastRow = 0;
};

#endif // INSTAGRAM_EXPLOREGRIDMODEL_H
