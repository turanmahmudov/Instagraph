#include "DirectEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QUuid>

namespace IG {

DirectEndpoint::DirectEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void DirectEndpoint::getInbox(const QString & cursorId) {
    auto builder = RequestBuilder::get("direct_v2/inbox/")
                       .queryParam("visual_message_return_type", "unseen")
                       .queryParam("persistentBadging", "true")
                       .queryParam("use_unified_inbox", "true");

    if (!cursorId.isEmpty()) {
        builder.queryParam("cursor", cursorId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit inboxReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::getPendingInbox() {
    auto request = RequestBuilder::get("direct_v2/pending_inbox/")
                       .queryParam("persistentBadging", "true")
                       .queryParam("use_unified_inbox", "true")
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit pendingInboxReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::getDirectThread(const QString & threadId, const QString & cursorId) {
    auto builder = RequestBuilder::get("direct_v2/threads/{thread_id}/")
                       .pathParam("thread_id", threadId)
                       .queryParam("use_unified_inbox", "true");

    if (!cursorId.isEmpty()) {
        builder.queryParam("cursor", cursorId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit directThreadReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::getRankedRecipients(const QString & query) {
    auto builder = RequestBuilder::get("direct_v2/ranked_recipients/")
                       .queryParam("mode", "raven")
                       .queryParam("show_threads", "true")
                       .queryParam("use_unified_inbox", "false");

    if (!query.isEmpty()) {
        builder.queryParam("query", query);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit rankedRecipientsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::markThreadSeen(const QString & threadId, const QString & threadItemId,
                                    const QString & uuid, const QString & csrfToken) {
    auto request = RequestBuilder::post("direct_v2/threads/{thread_id}/items/{item_id}/seen/")
                       .pathParam("thread_id", threadId)
                       .pathParam("item_id", threadItemId)
                       .param("_uuid", uuid)
                       .param("_csrftoken", csrfToken)
                       .param("use_unified_inbox", "true")
                       .param("action", "mark_seen")
                       .param("thread_id", threadId)
                       .param("item_id", threadItemId)
                       .unsigned_()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit threadMarkedSeen(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::sendMessage(const QString & recipients, const QString & text,
                                 const QString & threadId, const QString & uuid) {
    QString boundary = uuid;
    QString clientContext = QUuid::createUuid().toString();
    clientContext = clientContext.mid(1, clientContext.length() - 2);

    QByteArray body;
    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[[" + recipients.toUtf8() + "]]\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += clientContext.toUtf8() + "\r\n";

    if (threadId != "0" && !threadId.isEmpty()) {
        body += "--" + boundary.toUtf8() + "\r\n";
        body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
        body += "[\"" + threadId.toUtf8() + "\"]\r\n";
    }

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text.toUtf8() + "\r\n";

    body += "--" + boundary.toUtf8() + "--";

    auto request = RequestBuilder::post("direct_v2/threads/broadcast/text/")
                       .multipart(boundary)
                       .rawBody(body)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit messageReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::sendLike(const QString & recipients, const QString & threadId,
                              const QString & uuid) {
    QString boundary = uuid;
    QString clientContext = QUuid::createUuid().toString();
    clientContext = clientContext.mid(1, clientContext.length() - 2);
    QString mutationToken = QUuid::createUuid().toString();
    mutationToken = mutationToken.mid(1, mutationToken.length() - 2);

    QByteArray body;
    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"action\"\r\n\r\n";
    body += "send_item\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += clientContext.toUtf8() + "\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"mutation_token\"\r\n\r\n";
    body += mutationToken.toUtf8() + "\r\n";

    if (threadId != "0" && !threadId.isEmpty()) {
        body += "--" + boundary.toUtf8() + "\r\n";
        body += "Content-Disposition: form-data; name=\"thread_ids\"\r\n\r\n";
        body += "[\"" + threadId.toUtf8() + "\"]\r\n";
    } else {
        body += "--" + boundary.toUtf8() + "\r\n";
        body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
        body += "[[" + recipients.toUtf8() + "]]\r\n";
    }

    body += "--" + boundary.toUtf8() + "--";

    auto request = RequestBuilder::post("direct_v2/threads/broadcast/like/")
                       .multipart(boundary)
                       .rawBody(body)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit likeReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void DirectEndpoint::shareMedia(const QString & mediaId, const QString & recipients,
                                const QString & text, const QString & uuid) {
    QString boundary = uuid;
    QString clientContext = QUuid::createUuid().toString();
    clientContext = clientContext.mid(1, clientContext.length() - 2);

    QByteArray body;
    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"media_id\"\r\n\r\n";
    body += mediaId.toUtf8() + "\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"recipient_users\"\r\n\r\n";
    body += "[[" + recipients.toUtf8() + "]]\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"client_context\"\r\n\r\n";
    body += clientContext.toUtf8() + "\r\n";

    body += "--" + boundary.toUtf8() + "\r\n";
    body += "Content-Disposition: form-data; name=\"text\"\r\n\r\n";
    body += text.toUtf8() + "\r\n";

    body += "--" + boundary.toUtf8() + "--";

    auto request = RequestBuilder::post("direct_v2/threads/broadcast/media_share/")
                       .queryParam("media_type", "photo")
                       .multipart(boundary)
                       .rawBody(body)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit shareReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
