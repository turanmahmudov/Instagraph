#include "PeopleEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include "../utils/Constants.h"

namespace IG {

PeopleEndpoint::PeopleEndpoint(ApiClient* client, QObject* parent)
    : QObject(parent)
    , m_client(client)
{
}

void PeopleEndpoint::getInfoById(const QString& userId, const QString& deviceId) {
    auto request = RequestBuilder::get("users/{user_id}/info/")
        .pathParam("user_id", userId)
        .queryParam("device_id", deviceId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit infoByIdReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getInfoByName(const QString& username) {
    auto request = RequestBuilder::get("users/{username}/usernameinfo/")
        .pathParam("username", username)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit infoByNameReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::searchUsername(const QString& username) {
    auto request = RequestBuilder::get("users/{username}/usernameinfo/")
        .pathParam("username", username)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit searchUsernameReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getRecentActivityInbox() {
    auto request = RequestBuilder::get("news/inbox/")
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit recentActivityReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getFollowing(const QString& userId, const QString& maxId, 
                                  const QString& searchQuery, const QString& rankToken) {
    auto builder = RequestBuilder::get("friendships/{user_id}/following/")
        .pathParam("user_id", userId)
        .queryParam("rank_token", rankToken);
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }
    if (!searchQuery.isEmpty()) {
        builder.queryParam("query", searchQuery);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit followingReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getFollowers(const QString& userId, const QString& maxId, 
                                  const QString& searchQuery, const QString& rankToken) {
    auto builder = RequestBuilder::get("friendships/{user_id}/followers/")
        .pathParam("user_id", userId)
        .queryParam("rank_token", rankToken);
    
    if (!maxId.isEmpty()) {
        builder.queryParam("max_id", maxId);
    }
    if (!searchQuery.isEmpty()) {
        builder.queryParam("query", searchQuery);
    }

    m_client->execute(builder.build(), [this](const Response& response) {
        if (response.ok()) {
            emit followersReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getFriendship(const QString& userId) {
    auto request = RequestBuilder::get("friendships/show/{user_id}/")
        .pathParam("user_id", userId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit friendshipReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::follow(const QString& userId) {
    auto request = RequestBuilder::post("friendships/create/{user_id}/")
        .pathParam("user_id", userId)
        .param("user_id", userId)
        .param("radio_type", "wifi-none")
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit followReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::unfollow(const QString& userId) {
    auto request = RequestBuilder::post("friendships/destroy/{user_id}/")
        .pathParam("user_id", userId)
        .param("user_id", userId)
        .param("radio_type", "wifi-none")
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit unfollowReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::favorite(const QString& userId) {
    auto request = RequestBuilder::post("friendships/favorite/{user_id}/")
        .pathParam("user_id", userId)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit favoriteReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::unfavorite(const QString& userId) {
    auto request = RequestBuilder::post("friendships/unfavorite/{user_id}/")
        .pathParam("user_id", userId)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit unfavoriteReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::block(const QString& userId) {
    auto request = RequestBuilder::post("friendships/block/{user_id}/")
        .pathParam("user_id", userId)
        .param("user_id", userId)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit blockReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::unblock(const QString& userId) {
    auto request = RequestBuilder::post("friendships/unblock/{user_id}/")
        .pathParam("user_id", userId)
        .param("user_id", userId)
        .authenticated()
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit unblockReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getAutocompleteUserList() {
    auto request = RequestBuilder::get("friendships/autocomplete_user_list/")
        .queryParam("version", "2")
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit autocompleteUserListReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getBlockedUserList() {
    auto request = RequestBuilder::get("users/blocked_list/")
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit blockedUserListReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::searchUser(const QString& query, const QString& rankToken) {
    auto request = RequestBuilder::get("users/search/")
        .queryParam("query", query)
        .queryParam("is_typeahead", "true")
        .queryParam("rank_token", rankToken)
        .queryParam("ig_sig_key_version", Constants::sigKeyVersion())
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit searchUserReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void PeopleEndpoint::getSuggestedUser(const QString& userId) {
    auto request = RequestBuilder::get("discover/chaining/")
        .queryParam("target_id", userId)
        .build();

    m_client->execute(request, [this](const Response& response) {
        if (response.ok()) {
            emit suggestedUserReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

} // namespace IG
