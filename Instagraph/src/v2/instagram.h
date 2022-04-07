#ifndef INSTAGRAM_H
#define INSTAGRAM_H

#include <QObject>
#include <QScopedPointer>
#include <QVariant>

class QFile;
class QNetworkAccessManager;

class InstagramPrivate;
class Instagram : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    explicit Instagram(QObject *parent = 0);
    ~Instagram();

    bool busy() const;

public Q_SLOTS:
    Q_INVOKABLE QString photos_path();

    Q_INVOKABLE void login(bool forse = false, QString username = "", QString password = "", bool set = false);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void confirm2Factor(QString code, QString identifier, QString method);
    //Maked there
    Q_INVOKABLE void setUsername(QString username);
    Q_INVOKABLE void setPassword(QString password);
    Q_INVOKABLE QString getUsernameId();
    Q_INVOKABLE void setProfilePic(QString userpic);
    Q_INVOKABLE QString getProfilePic();
    //End

    Q_INVOKABLE void postImage(QString path, QString caption, QVariantMap location, QString upload_id = "", QString disableComments = "0");
    Q_INVOKABLE void postVideo(QFile *video);

    //Unnown source of funct
    Q_INVOKABLE void getPopularFeed(QString max_id = "");
    Q_INVOKABLE void searchUsername(QString username);

    //Image manipulate
    Q_INVOKABLE void rotateImg(QString filename, qreal deg);
    Q_INVOKABLE void cropImg(QString filename, bool squared, bool isRotated = true);
    Q_INVOKABLE void cropImg(QString in_filename, QString out_filename, int topSpace, bool squared);
    Q_INVOKABLE void scaleImg(QString filename);

    //Account
    Q_INVOKABLE void setPrivateAccount();
    Q_INVOKABLE void setPublicAccount();
    Q_INVOKABLE void changeProfilePicture(QFile *photo);
    Q_INVOKABLE void removeProfilePicture();
    Q_INVOKABLE void getCurrentUser();
    Q_INVOKABLE void editProfile(QString url, QString phone, QString first_name, QString biography, QString email, bool gender);
    Q_INVOKABLE void checkUsername(QString username);
    Q_INVOKABLE void createAccount(QString username, QString password, QString email);

    //Direct
    Q_INVOKABLE void getInbox(QString cursorId = "");
    Q_INVOKABLE void getDirectThread(QString threadId, QString cursorId="");
    Q_INVOKABLE void getPendingInbox();
    Q_INVOKABLE void getRecentRecipients();
    Q_INVOKABLE void getRankedRecipients(QString query = "");
    Q_INVOKABLE void markThreadSeen(QString threadId, QString threadItemId);
    Q_INVOKABLE void directMessage(QString recipients, QString text, QString thread_id = "0");
    Q_INVOKABLE void directLike(QString recipients, QString thread_id = "0");
    Q_INVOKABLE void directShare(QString mediaId, QString recipients, QString text = "");

    //Discover
    Q_INVOKABLE void getExploreFeed(QString max_id="");
    Q_INVOKABLE void getSuggestions();

    //FBSearch
    Q_INVOKABLE void recentSearches();
    Q_INVOKABLE void searchPlaces(QString query);

    //Location
    Q_INVOKABLE void getGeoMedia(QString usernameId);
    Q_INVOKABLE void getLocationFeed(QString locationId, QString max_id = "");

    // Location Search
    Q_INVOKABLE void searchLocation(QString lat, QString lng, QString query = "");

    //Hashtag
    Q_INVOKABLE void getTagFeed(QString tag, QString max_id="");
    Q_INVOKABLE void searchTags(QString tag);

    // Highlight
    Q_INVOKABLE void getUserHighlightFeed(QString userId);

    //Media
    Q_INVOKABLE void getInfoMedia(QString mediaId);
    Q_INVOKABLE void editMedia(QString mediaId, QString captionText = "", QString mediaType = "PHOTO");
    Q_INVOKABLE void deleteMedia(QString mediaId, QString mediaType = "PHOTO");
    Q_INVOKABLE void like(QString mediaId, QString module="feed_contextual_post");
    Q_INVOKABLE void unLike(QString mediaId, QString module="feed_contextual_post");
    Q_INVOKABLE void getLikedFeed(QString max_id="");
    Q_INVOKABLE void comment(QString mediaId, QString commentText, QString replyCommentId = "", QString module="coments_feed_timeline");
    Q_INVOKABLE void deleteComment(QString mediaId, QString commentId);
    Q_INVOKABLE void likeComment(QString commentId);
    Q_INVOKABLE void unlikeComment(QString commentId);
    Q_INVOKABLE void getComments(QString mediaId, QString max_id="");
    Q_INVOKABLE void getLikedMedia(QString max_id = "");
    Q_INVOKABLE void getMediaLikers(QString mediaId);
    Q_INVOKABLE void enableMediaComments(QString mediaId);
    Q_INVOKABLE void disableMediaComments(QString mediaId);
    Q_INVOKABLE void saveMedia(QString mediaId);
    Q_INVOKABLE void unsaveMedia(QString mediaId);
    Q_INVOKABLE void getSavedFeed(QString max_id = "");

    //People
    Q_INVOKABLE void getInfoById(QString userId);
    Q_INVOKABLE void getInfoByName(QString username);
    Q_INVOKABLE void getRecentActivityInbox();
    Q_INVOKABLE void getFollowing(QString userId, QString max_id = "", QString searchQuery="");
    Q_INVOKABLE void getFollowers(QString userId, QString max_id = "", QString searchQuery="");
    Q_INVOKABLE void getFriendship(QString userId);
    Q_INVOKABLE void getSugestedUser(QString userId);
    Q_INVOKABLE void getAutocompleteUserList();
    Q_INVOKABLE void getBlockedUserList();

    Q_INVOKABLE void favorite(QString userId);
    Q_INVOKABLE void unFavorite(QString userId);
    Q_INVOKABLE void follow(QString userId);
    Q_INVOKABLE void unFollow(QString userId);
    Q_INVOKABLE void block(QString userId);
    Q_INVOKABLE void unBlock(QString userId);

    Q_INVOKABLE void searchUser(QString query);

    //Story
    Q_INVOKABLE void getReelsTrayFeed();
    Q_INVOKABLE void getUserReelsMediaFeed(QString userId);
    Q_INVOKABLE void markStoryMediaSeen(QString reels);
    Q_INVOKABLE void getReelsMediaFeed(QString id);

    //Timeline
    Q_INVOKABLE void getTimelineFeed(QString max_id = "", QString seen_posts = "", bool pullToRefresh = false);
    Q_INVOKABLE void getUserFeed(QString userID, QString max_id = "", QString minTimestamp = "");

    //Usertag
    Q_INVOKABLE void getUserTags(QString userId, QString max_id="", QString minTimestamp="");
    Q_INVOKABLE void removeSelftag(QString mediaId);

    void setNetworkAccessManager(QNetworkAccessManager *nam);
    QNetworkAccessManager *networkAccessManager() const;

Q_SIGNALS:
    void profileConnected(QVariant answer);
    void profileConnectedFail();
    void twoFactorRequired(QVariant answer);
    void challengeRequired(QVariant answer);

    void doLogout(QVariant answer);
    void error(QString message);

    void busyChanged();

    void imageConfigureDataReady(QVariant answer);
    void imageUploadProgressDataReady(double answer);

    //Unnown source
    void popularFeedDataReady(QVariant answer);
    void searchUsernameDataReady(QVariant answer);

    //Refactored

    void imgSquared();
    void imgRotated();
    void imgCropped();
    void imgScaled();

    //Account
    void profilePictureDeleted(QVariant answer);
    void setProfilePrivate(QVariant answer);
    void setProfilePublic(QVariant answer);
    void currentUserDataReady(QVariant answer);
    void editDataReady(QVariant answer);
    void usernameCheckDataReady(QVariant answer);
    void createAccountDataReady(QVariant answer);

    //Direct
    void inboxDataReady(QVariant answer);
    void directThreadDataReady(QVariant answer);
    void pendingInboxDataReady(QVariant answer);
    void recentRecipientsDataReady(QVariant answer);
    void rankedRecipientsDataReady(QVariant answer);
    void markThreadSeenDataReady(QVariant answer);
    void directMessageDataReady(QVariant answer);
    void directLikeDataReady(QVariant answer);
    void directShareDataReady(QVariant answer);

    //Discover
    void exploreFeedDataReady(QVariant answer);
    void suggestionsFeedDataReady(QVariant answer);

    //FBSearch
    void recentSearchesDataReady(QVariant answer);
    void searchPlacesDataReady(QVariant answer);

    //Location
    void geoMediaDataReady(QVariant answer);
    void getLocationFeedDataReady(QVariant answer);

    // Location Search
    void searchLocationDataReady(QVariant answer);

    //Hashtag
    void tagFeedDataReady(QVariant answer);
    void searchTagsDataReady(QVariant answer);

    // Highlight
    void userHighlightFeedDataReady(QVariant answer);

    //Media
    void likeDataReady(QVariant answer);
    void unLikeDataReady(QVariant answer);
    void likedFeedDataReady(QVariant answer);
    void mediaInfoReady(QVariant answer);
    void mediaEdited(QVariant answer);
    void mediaDeleted(QVariant answer);
    void commentPosted(QVariant answer);
    void commentDeleted(QVariant answer);
    void commentLiked(QVariant answer);
    void commentUnliked(QVariant answer);
    void mediaCommentsDataReady(QVariant answer);
    void likedMediaDataReady(QVariant answer);
    void mediaLikersDataReady(QVariant answer);
    void enableMediaCommentsDataReady(QVariant answer);
    void disableMediaCommentsDataReady(QVariant answer);
    void saveMediaDataReady(QVariant answer);
    void unsaveMediaDataReady(QVariant answer);
    void savedFeedDataReady(QVariant answer);

    //People
    void followingDataReady(QVariant answer);
    void followersDataReady(QVariant answer);
    void followDataReady(QVariant answer);
    void unfollowDataReady(QVariant answer);
    void favoriteDataReady(QVariant answer);
    void unFavoriteDataReady(QVariant answer);
    void blockDataReady(QVariant answer);
    void unBlockDataReady(QVariant answer);

    void infoByIdDataReady(QVariant answer);
    void infoByNameDataReady(QVariant answer);

    void recentActivityInboxDataReady(QVariant answer);
    void followingRecentActivityDataReady(QVariant answer);
    void friendshipDataReady(QVariant answer);
    void autocompleteUserListDataReady(QVariant answer);
    void searchUserDataReady(QVariant answer);
    void suggestedUserDataReady(QVariant answer);
    void blockedUserListDataReady(QVariant answer);

    //Story
    void reelsTrayFeedDataReady(QVariant answer);
    void userReelsMediaFeedDataReady(QVariant answer);
    void markStoryMediaSeenDataReady(QVariant answer);
    void reelsMediaFeedDataReady(QVariant answer);

    //Timeline
    void userFeedDataReady(QVariant answer);
    void timelineFeedDataReady(QVariant answer);

    //Usertags
    void userTagsDataReady(QVariant answer);
    void removeSelftagDone(QVariant answer);

private:
    Q_DECLARE_PRIVATE(Instagram)
    bool m_busy;
    QScopedPointer<InstagramPrivate> d_ptr;
};

#endif // INSTAGRAM_H
