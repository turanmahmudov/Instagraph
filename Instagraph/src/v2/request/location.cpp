#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::searchFBLocation(QString query)
{
    Q_D(Instagram);

    InstagramRequest *searchFBLocationRequest =
        d->request("fbsearch/places/?"
                   "query="+query+"&"
                   "rank_token="+d->m_rank_token, NULL, false,true);
    QObject::connect(searchFBLocationRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(searchFBLocationDataReady(QVariant)));
}

void Instagram::getGeoMedia(QString usernameId)
{
    Q_D(Instagram);

    InstagramRequest *getGeoMediaRequest =
        d->request("maps/user/"+usernameId+"/",NULL,false,true);
    QObject::connect(getGeoMediaRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(geoMediaDataReady(QVariant)));
}

void Instagram::getLocationFeed(QString locationId, QString max_id)
{
    Q_D(Instagram);

    QString target ="feed/location/"+locationId+"/";

    if(max_id.length() > 0)
    {
        target += "?max_id="+max_id;
    }

    InstagramRequest *getLocationFeedRequest =
        d->request(target,NULL);
    QObject::connect(getLocationFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(getLocationFeedDataReady(QVariant)));
}
