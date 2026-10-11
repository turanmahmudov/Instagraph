#ifndef INSTAGRAM_SEARCHRESULTMODEL_H
#define INSTAGRAM_SEARCHRESULTMODEL_H

#include "JsonListModel.h"

class SearchResultModel : public JsonListModel {
    Q_OBJECT
public:
    explicit SearchResultModel(QObject * parent = nullptr);

protected:
    // options.type: recentSearches, searchUsers, searchTags, searchLocation or searchVenues
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_SEARCHRESULTMODEL_H
