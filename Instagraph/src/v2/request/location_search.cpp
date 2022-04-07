#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::searchLocation(QString lat, QString lng, QString query)
{
    Q_D(Instagram);

    QString target = "location_search/"
                     "?rank_token="+d->m_rank_token+
                     "&latitude="+lat+
                     "&longitude="+lng;

    if(query.length() > 0)
    {
        target += "&search_query="+query;
    }
    else
    {
        target += "&timestamp="+QString::number(QDateTime::currentMSecsSinceEpoch());
    }

    InstagramRequest *searchLocationRequest =
        d->request(target, NULL, false, true);
    QObject::connect(searchLocationRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(searchLocationDataReady(QVariant)));
}
