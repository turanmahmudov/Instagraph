#include "../instagram_p.h"
#include "../instagramrequest.h"
#include <QJsonObject>

void Instagram::getInfoByName(QString username)
{
    Q_D(Instagram);

    InstagramRequest *getInfoByNameRequest =
        d->request("users/"+username+"/usernameinfo/",NULL,false,true);
    QObject::connect(getInfoByNameRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(infoByNameDataReady(QVariant)));
}

//old getUsernameInfo
void Instagram::getInfoById(QString userId)
{
    Q_D(Instagram);

    InstagramRequest *getInfoByIdRequest =
        d->request("users/"+userId+"/info/"
                   "?device_id="+d->m_device_id
                   ,NULL, false, true);
    QObject::connect(getInfoByIdRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(infoByIdDataReady(QVariant)));
}

//old getRecentActivity
void Instagram::getRecentActivityInbox()
{
    Q_D(Instagram);

    InstagramRequest *getRecentActivityInboxRequest =
        d->request("news/inbox/?",NULL);
    QObject::connect(getRecentActivityInboxRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(recentActivityInboxDataReady(QVariant)));
}

void Instagram::getFriendship(QString userId)
{
    Q_D(Instagram);

    InstagramRequest *getFriendshipRequest =
        d->request("friendships/show/"+userId+"/",NULL,false,true);
    QObject::connect(getFriendshipRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(friendshipDataReady(QVariant)));
}

void Instagram::getFollowing(QString userId, QString max_id, QString searchQuery)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    InstagramRequest *getFollowingRequest =
        d->request("friendships/"+userId+"/following/?"
                   "rank_token="+d->m_rank_token +
                   (max_id.length()>0 ? "&max_id="+max_id : "") +
                   (searchQuery.length()>0 ? "&query="+searchQuery : "")
                   ,NULL,false,true);
    QObject::connect(getFollowingRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(followingDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}

void Instagram::getFollowers(QString userId, QString max_id, QString searchQuery)
{
    Q_D(Instagram);

    m_busy = true;
    Q_EMIT busyChanged();

    InstagramRequest *getFollowersRequest =
        d->request("friendships/"+userId+"/followers/?"
                   "rank_token="+d->m_rank_token +
                   (max_id.length()>0 ? "&max_id="+max_id : "") +
                   (searchQuery.length()>0 ? "&query="+searchQuery : "")
                   ,NULL,false,true);
    QObject::connect(getFollowersRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(followersDataReady(QVariant)));

    m_busy = false;
    Q_EMIT busyChanged();
}

void Instagram::getAutocompleteUserList()
{
    Q_D(Instagram);

    InstagramRequest *getAutocompleteUserListRequest =
        d->request("friendships/autocomplete_user_list/?version=2",NULL);
    QObject::connect(getAutocompleteUserListRequest,SIGNAL(replySrtingReady(QVariant)),this,SIGNAL(autocompleteUserListDataReady(QVariant)));
}

//userFeed
void Instagram::searchUser(QString query)
{
    Q_D(Instagram);

    InstagramRequest *getSearchUserRequest =
        d->request("users/search/?"
                   "query="+query+
                   "&is_typeahead=true&"
                   "rank_token="+d->m_rank_token+
                   "&ig_sig_key_version="+Constants::sigKeyVersion()
                   ,NULL,false,true);
    QObject::connect(getSearchUserRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(searchUserDataReady(QVariant)));
}

void Instagram::follow(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    data.insert("user_id",      userId);
    data.insert("radio_type",   "wifi-none");
    QString signature = InstagramRequest::generateSignature(data);

    InstagramRequest *followRequest =
        d->request("friendships/create/"+userId+"/"
                   ,signature.toUtf8());
    QObject::connect(followRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(followDataReady(QVariant)));
}

void Instagram::unFollow(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    data.insert("user_id",      userId);
    data.insert("radio_type",   "wifi-none");
    QString signature = InstagramRequest::generateSignature(data);

    InstagramRequest *unFollowRequest =
        d->request("friendships/destroy/"+userId+"/"
                   ,signature.toUtf8());
    QObject::connect(unFollowRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(unfollowDataReady(QVariant)));
}

void Instagram::favorite(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    QString signature = InstagramRequest::generateSignature(data);

    InstagramRequest *favoriteRequest =
        d->request("friendships/favorite/"+userId+"/"
                   ,signature.toUtf8());
    QObject::connect(favoriteRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(favoriteDataReady(QVariant)));
}

void Instagram::unFavorite(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    QString signature = InstagramRequest::generateSignature(data);

    InstagramRequest *unFavoriteRequest =
        d->request("friendships/unfavorite/"+userId+"/"
                   ,signature.toUtf8());
    QObject::connect(unFavoriteRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(unFavoriteDataReady(QVariant)));
}

void Instagram::block(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    data.insert("user_id",      userId);
    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *blockRequest =
        d->request("friendships/block/" + userId + "/?"
                   ,signature.toUtf8());
    QObject::connect(blockRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(blockDataReady(QVariant)));
}

void Instagram::unBlock(QString userId)
{
    Q_D(Instagram);

    QJsonObject data;
    data.insert("_uuid",        d->m_uuid);
    data.insert("_uid",         d->m_username_id);
    data.insert("_csrftoken",   "Set-Cookie: csrftoken="+d->m_token);
    data.insert("user_id",      userId);

    QString signature = InstagramRequest::generateSignature(data);
    InstagramRequest *unBlockRequest =
        d->request("friendships/unblock/" + userId + "/"
                   ,signature.toUtf8());
    QObject::connect(unBlockRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(unBlockDataReady(QVariant)));
}

void Instagram::getBlockedUserList()
{
    Q_D(Instagram);

    InstagramRequest *getBlockedUserListRequest =
        d->request("users/blocked_list/",NULL);
    QObject::connect(getBlockedUserListRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(blockedUserListDataReady(QVariant)));
}

void Instagram::getSugestedUser(QString userId)
{
    Q_D(Instagram);

    InstagramRequest *getSuggestedRequest =
        d->request("discover/chaining/?"
                   "target_id="+userId
                   ,NULL);
    QObject::connect(getSuggestedRequest,SIGNAL(replyStringReady(QVariant)),this,SIGNAL(suggestedUserDataReady(QVariant)));
}
