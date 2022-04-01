#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

//userFeed
void Instagram::recentSearches()
{
    Q_D(Instagram);

    InstagramRequest *recentSearchesRequest =
        d->request("fbsearch/recent_searches/",NULL,false,true);
    QObject::connect(recentSearchesRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(recentSearchesDataReady(QVariant)));
}

void Instagram::searchPlaces(QString query)
{
    Q_D(Instagram);

    InstagramRequest *searchFBLocationRequest =
        d->request("fbsearch/places/?"
                   "query="+query+"&"
                   "rank_token="+d->m_rank_token, NULL, false,true);
    QObject::connect(searchFBLocationRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(searchPlacesDataReady(QVariant)));
}
