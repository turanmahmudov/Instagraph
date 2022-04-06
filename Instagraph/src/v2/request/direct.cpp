#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>
#include <QUuid>

void Instagram::getInbox(QString cursorId)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    InstagramRequest *getInboxRequest =
        d->request("direct_v2/inbox/?"
                   "visual_message_return_type=unseen&"
                   "persistentBadging=true&"
                   "use_unified_inbox=true" +
                   (cursorId.length()>0 ? "&cursor=" + cursorId : "")
                   , NULL);
    QObject::connect(getInboxRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(inboxDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}

void Instagram::getPendingInbox()
{
    Q_D(Instagram);

    InstagramRequest *getPendingInboxRequest =
        d->request("direct_v2/pending_inbox/"
                   "persistentBadging=true&"
                   "use_unified_inbox=true"
                   , NULL);
    QObject::connect(getPendingInboxRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(pendingInboxDataReady(QVariant)));
}

void Instagram::getDirectThread(QString threadId, QString cursorId)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    InstagramRequest *getDirectThreadRequest =
        d->request("direct_v2/threads/"+threadId+"/?"
                   "use_unified_inbox=true"+
                   (cursorId.length()>0 ? "&cursor="+cursorId : "")
                   , NULL);
    QObject::connect(getDirectThreadRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(directThreadDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}

void Instagram::getRecentRecipients()
{
    Q_D(Instagram);

    InstagramRequest *getRecentRecipientsRequest =

        d->request("direct_share/recent_recipients/", NULL, false, true);
    QObject::connect(getRecentRecipientsRequest,SIGNAL(replyStringReady(QVariant)), this, SIGNAL(recentRecipientsDataReady(QVariant)));

}

void Instagram::getRankedRecipients(QString query)
{
    Q_D(Instagram);

    QString target = "direct_v2/ranked_recipients/?mode=raven&show_threads=true&use_unified_inbox=false&";
    if(query.length() > 0)
    {
        target += "&query="+query;
    }
    else
    {
        target += "&";
    }

    InstagramRequest *getRankedRecipientsRequest =
        d->request(target, NULL, false, true);
    QObject::connect(getRankedRecipientsRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(rankedRecipientsDataReady(QVariant)));
}

void Instagram::markThreadSeen(QString threadId, QString threadItemId)
{
    Q_D(Instagram);

    QJsonObject data;
        data.insert("_uuid",        d->m_uuid);
        data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
        data.insert("use_unified_inbox", "true");
        data.insert("action",       "mark_seen");
        data.insert("thread_id",    threadId);
        data.insert("item_id",      threadItemId);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *markThreadSeenRequest =
        d->request("direct_v2/threads/"+threadId+"/items/"+threadItemId+"/seen/", signature.toUtf8());
    QObject::connect(markThreadSeenRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(markThreadSeenDataReady(QVariant)));
}

void Instagram::directMessage(QString recipients, QString text, QString thread_id)
{
    Q_D(Instagram);

    QString boundary = d->m_uuid;

    QUuid uuid;

    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += uuid.createUuid().toString().replace("{","").replace("}","")+"\r\n";

    if (thread_id != "") {
        body += "--"+boundary+"\r\n";
        body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
        body += "[\""+thread_id+"\"]\r\n";
    }

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text+"\r\n";

    body += "--"+boundary+"--";

    InstagramRequest *directMessageRequest =
        d->directRequest("direct_v2/threads/broadcast/text/",boundary, body);

    QObject::connect(directMessageRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(directMessageDataReady(QVariant)));
}

void Instagram::directShare(QString mediaId, QString recipients, QString text)
{
    Q_D(Instagram);

    QString boundary = d->m_uuid;

    QUuid uuid;

    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"media_id\"\r\n\r\n";
    body += mediaId+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += uuid.createUuid().toString().replace("{","").replace("}","")+"\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text+"\r\n";

    body += "--"+boundary+"--";

    InstagramRequest *directShareRequest =
        d->directRequest("direct_v2/threads/broadcast/media_share/?media_type=photo",boundary, body);

    QObject::connect(directShareRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(directShareDataReady(QVariant)));
}

void Instagram::directLike(QString recipients, QString thread_id)
{
    Q_D(Instagram);

    QString boundary = d->m_uuid;

    QUuid uuid;

    /*Body build*/
    QByteArray body = "";
    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[["+recipients+"]]\r\n";

    body += "--"+boundary+"\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += uuid.createUuid().toString().replace("{","").replace("}","")+"\r\n";

    if (thread_id != "") {
        body += "--"+boundary+"\r\n";
        body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
        body += "[\""+thread_id+"\"]\r\n";
    }

    body += "--"+boundary+"--";

    InstagramRequest *directLikeRequest =
        d->directRequest("direct_v2/threads/broadcast/like/",boundary, body);

    QObject::connect(directLikeRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(directLikeDataReady(QVariant)));
}
