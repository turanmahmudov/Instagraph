#ifndef INSTAGRAM_MEDIAFEEDMODEL_H
#define INSTAGRAM_MEDIAFEEDMODEL_H

#include "JsonListModel.h"

class MediaFeedModel : public JsonListModel {
    Q_OBJECT
public:
    explicit MediaFeedModel(QObject * parent = nullptr);

    Q_INVOKABLE int countSectionMedia(const QString & path) const;

protected:
    // options.savedMedia: the items are saved-media wrappers with the media under "media"
    // options.sections: the items are tag or location feed sections
    QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                      const QVariantMap & options, bool clear,
                      QVector<QVariantMap> & rows) override;
};

#endif // INSTAGRAM_MEDIAFEEDMODEL_H
