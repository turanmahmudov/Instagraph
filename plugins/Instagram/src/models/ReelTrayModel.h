#ifndef INSTAGRAM_REELTRAYMODEL_H
#define INSTAGRAM_REELTRAYMODEL_H

#include "JsonListModel.h"

class ReelTrayModel : public JsonListModel {
    Q_OBJECT
public:
    explicit ReelTrayModel(QObject * parent = nullptr);

protected:
    // options.stringIds: convert the reel id to a string
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_REELTRAYMODEL_H
