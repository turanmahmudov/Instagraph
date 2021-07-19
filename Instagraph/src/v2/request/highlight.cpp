#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::getUserHighlightFeed(QString userId)
{
    Q_D(Instagram);

    InstagramRequest *getUserHighlightFeedRequest =
        d->request("highlights/"+userId+"/highlights_tray/"
                   ,NULL, false, true);
    QObject::connect(getUserHighlightFeedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(userHighlightFeedDataReady(QVariant)));
}
