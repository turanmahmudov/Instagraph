#ifndef INSTAGRAM_PEOPLEENDPOINT_H
#define INSTAGRAM_PEOPLEENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all people/user-related API operations.
 *
 * This endpoint manages:
 * - User info retrieval
 * - Following/followers
 * - Friendship actions (follow, unfollow, block)
 * - User search
 * - Suggested users
 */
class PeopleEndpoint : public QObject {
    Q_OBJECT

public:
    explicit PeopleEndpoint(ApiClient * client, QObject * parent = nullptr);

    // User info
    void getInfoById(const QString & userId, const QString & deviceId = "");
    void getInfoByName(const QString & username);
    void searchUsername(const QString & username);

    // Activity
    void getRecentActivityInbox();

    // Relationships
    void getFollowing(const QString & userId, const QString & maxId = "",
                      const QString & searchQuery = "", const QString & rankToken = "");
    void getFollowers(const QString & userId, const QString & maxId = "",
                      const QString & searchQuery = "", const QString & rankToken = "");
    void getFriendship(const QString & userId);

    // Friendship actions
    void follow(const QString & userId);
    void unfollow(const QString & userId);
    void favorite(const QString & userId);
    void unfavorite(const QString & userId);
    void block(const QString & userId);
    void unblock(const QString & userId);

    // Follow requests
    void getPendingFriendships();
    void approveFriendship(const QString & userId);
    void rejectFriendship(const QString & userId);

    // Lists
    void getAutocompleteUserList();
    void getBlockedUserList();

    // Search
    void searchUser(const QString & query, const QString & rankToken = "");

    // Suggestions
    void getSuggestedUser(const QString & userId);

Q_SIGNALS:
    void infoByIdReady(const QVariant & answer);
    void infoByNameReady(const QVariant & answer);
    void searchUsernameReady(const QVariant & answer);
    void recentActivityReady(const QVariant & answer);
    void followingReady(const QVariant & answer);
    void followersReady(const QVariant & answer);
    void friendshipReady(const QVariant & answer);
    void followReady(const QVariant & answer);
    void unfollowReady(const QVariant & answer);
    void favoriteReady(const QVariant & answer);
    void unfavoriteReady(const QVariant & answer);
    void blockReady(const QVariant & answer);
    void unblockReady(const QVariant & answer);
    void pendingFriendshipsReady(const QVariant & answer);
    void approveFriendshipReady(const QVariant & answer);
    void rejectFriendshipReady(const QVariant & answer);
    void autocompleteUserListReady(const QVariant & answer);
    void blockedUserListReady(const QVariant & answer);
    void searchUserReady(const QVariant & answer);
    void suggestedUserReady(const QVariant & answer);
    void error(const QString & message);

private:
    ApiClient * m_client;
};

} // namespace IG

#endif // INSTAGRAM_PEOPLEENDPOINT_H
