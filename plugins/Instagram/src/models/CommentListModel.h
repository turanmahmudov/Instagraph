#ifndef INSTAGRAM_COMMENTLISTMODEL_H
#define INSTAGRAM_COMMENTLISTMODEL_H

#include "JsonListModel.h"

class CommentListModel : public JsonListModel {
    Q_OBJECT
public:
    explicit CommentListModel(QObject * parent = nullptr);

protected:
    // options.isCaption: the items are the media caption
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_COMMENTLISTMODEL_H
