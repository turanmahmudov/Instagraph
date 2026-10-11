#ifndef INSTAGRAM_TIMELINEFEEDMODEL_H
#define INSTAGRAM_TIMELINEFEEDMODEL_H

#include "JsonListModel.h"

#include <QPointer>

class TimelineFeedModel : public JsonListModel {
    Q_OBJECT
    Q_PROPERTY(JsonListModel * suggestionsModel READ findSuggestionsModel WRITE setSuggestionsModel
                   NOTIFY suggestionsModelChanged)
public:
    explicit TimelineFeedModel(QObject * parent = nullptr);

    JsonListModel * findSuggestionsModel() const;
    void setSuggestionsModel(JsonListModel * model);

signals:
    void suggestionsModelChanged();

protected:
    // Returns {seenPosts: [media id], endOfFeed: [{title, subtitle, pause, style}]}
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;

private:
    QPointer<JsonListModel> m_suggestionsModel;
};

#endif // INSTAGRAM_TIMELINEFEEDMODEL_H
