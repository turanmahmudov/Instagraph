#include "MediaEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include <QUuid>

namespace IG {

MediaEndpoint::MediaEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void MediaEndpoint::like(const QString & mediaId, const QString & module) {
    auto request = RequestBuilder::post("media/{media_id}/like/")
                       .pathParam("media_id", mediaId)
                       .param("media_id", mediaId)
                       .param("module_name", module)
                       .param("radio_type", "wifi-none")
                       .queryParam("d", "1")
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit likeReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::unlike(const QString & mediaId, const QString & module) {
    auto request = RequestBuilder::post("media/{media_id}/unlike/")
                       .pathParam("media_id", mediaId)
                       .param("media_id", mediaId)
                       .param("module_name", module)
                       .param("radio_type", "wifi-none")
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit unlikeReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::getLikedMedia(const QString & maxId) {
    auto builder = RequestBuilder::get("feed/liked/");
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit likedMediaReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::getMediaLikers(const QString & mediaId) {
    auto request =
        RequestBuilder::get("media/{media_id}/likers/").pathParam("media_id", mediaId).build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaLikersReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::getInfo(const QString & mediaId) {
    auto request =
        RequestBuilder::get("media/{media_id}/info/").pathParam("media_id", mediaId).build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaInfoReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::edit(const QString & mediaId, const QString & captionText,
                         const QString & mediaType) {
    Q_UNUSED(mediaType);

    auto request = RequestBuilder::post("media/{media_id}/edit_media/")
                       .pathParam("media_id", mediaId)
                       .param("caption_text", captionText)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaEdited(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::deleteMedia(const QString & mediaId, const QString & mediaType) {
    auto request = RequestBuilder::post("media/{media_id}/delete/")
                       .pathParam("media_id", mediaId)
                       .queryParam("media_type", mediaType)
                       .param("media_id", mediaId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaDeleted(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::postComment(const QString & mediaId, const QString & commentText,
                                const QString & replyCommentId, const QString & module) {
    QString idempotenceToken = QUuid::createUuid().toString();
    idempotenceToken = idempotenceToken.mid(1, idempotenceToken.length() - 2);

    auto builder = RequestBuilder::post("media/{media_id}/comment/")
                       .pathParam("media_id", mediaId)
                       .param("comment_text", commentText)
                       .param("containermodule", module)
                       .param("idempotence_token", idempotenceToken)
                       .param("radio_type", "wifi-none")
                       .authenticated();

    if (!replyCommentId.isEmpty() && replyCommentId.at(0) == '@') {
        builder.param("replied_to_comment_id", replyCommentId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit commentPosted(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::deleteComment(const QString & mediaId, const QString & commentId) {
    auto request = RequestBuilder::post("media/{media_id}/comment/{comment_id}/delete/")
                       .pathParam("media_id", mediaId)
                       .pathParam("comment_id", commentId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit commentDeleted(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::likeComment(const QString & commentId) {
    auto request = RequestBuilder::post("media/{comment_id}/comment_like/")
                       .pathParam("comment_id", commentId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit commentLiked(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::unlikeComment(const QString & commentId) {
    auto request = RequestBuilder::post("media/{comment_id}/comment_unlike/")
                       .pathParam("comment_id", commentId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit commentUnliked(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::getComments(const QString & mediaId, const QString & maxId) {
    auto builder = RequestBuilder::get("media/{media_id}/comments/")
                       .pathParam("media_id", mediaId)
                       .queryParam("can_support_threading", "true");

    if (!maxId.isEmpty()) {
        builder.queryParam("min_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit commentsReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::enableComments(const QString & mediaId) {
    auto request = RequestBuilder::post("media/{media_id}/enable_comments/")
                       .pathParam("media_id", mediaId)
                       .unsigned_()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit commentsEnabled(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::disableComments(const QString & mediaId) {
    auto request = RequestBuilder::post("media/{media_id}/disable_comments/")
                       .pathParam("media_id", mediaId)
                       .unsigned_()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit commentsDisabled(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::save(const QString & mediaId) {
    auto request = RequestBuilder::post("media/{media_id}/save/")
                       .pathParam("media_id", mediaId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaSaved(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::unsave(const QString & mediaId) {
    auto request = RequestBuilder::post("media/{media_id}/unsave/")
                       .pathParam("media_id", mediaId)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit mediaUnsaved(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void MediaEndpoint::getSavedFeed(const QString & maxId) {
    auto builder = RequestBuilder::get("feed/saved/");
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }

    m_client->execute(builder.build(), [this](const Response & response) {
        if (response.ok()) {
            emit savedFeedReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
