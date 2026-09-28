#include "Instagram.h"
#include "../core/ApiClient.h"
#include "../crypto/PasswordEncryptor.h"
#include "../endpoints/AccountEndpoint.h"
#include "../endpoints/DirectEndpoint.h"
#include "../endpoints/FeedEndpoint.h"
#include "../endpoints/HashtagEndpoint.h"
#include "../endpoints/LocationEndpoint.h"
#include "../endpoints/MediaEndpoint.h"
#include "../endpoints/PeopleEndpoint.h"
#include "../endpoints/SearchEndpoint.h"
#include "../endpoints/StoryEndpoint.h"
#include "../endpoints/UploadEndpoint.h"
#include "../endpoints/UsertagEndpoint.h"
#include "../network/CookieManager.h"
#include "../session/SessionManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QUuid>

Instagram::Instagram(QObject * parent)
    : QObject(parent), m_isLoggedIn(false), m_session(nullptr), m_cookies(nullptr),
      m_client(nullptr), m_account(nullptr), m_media(nullptr), m_direct(nullptr), m_feed(nullptr),
      m_people(nullptr), m_story(nullptr), m_hashtag(nullptr), m_location(nullptr),
      m_search(nullptr), m_usertag(nullptr), m_upload(nullptr), m_passwordEncryptor(nullptr) {
    initializeComponents();
    setupEndpointConnections();
}

Instagram::~Instagram() {
    // Qt parent-child will handle cleanup
}

void Instagram::initializeComponents() {
    // Create session manager
    m_session = new IG::SessionManager(this);

    // Create cookie manager with data path from session
    m_cookies = new IG::CookieManager(m_session->dataPath().absolutePath(), this);

    // Create API client (replaces RequestExecutor)
    m_client = new IG::ApiClient(m_session, m_cookies, this);

    // Create all endpoints - new pattern: pass only ApiClient
    m_account = new IG::AccountEndpoint(m_client, this);
    m_media = new IG::MediaEndpoint(m_client, this);
    m_direct = new IG::DirectEndpoint(m_client, this);
    m_feed = new IG::FeedEndpoint(m_client, this);
    m_people = new IG::PeopleEndpoint(m_client, this);
    m_story = new IG::StoryEndpoint(m_client, this);
    m_hashtag = new IG::HashtagEndpoint(m_client, this);
    m_location = new IG::LocationEndpoint(m_client, this);
    m_search = new IG::SearchEndpoint(m_client, this);
    m_usertag = new IG::UsertagEndpoint(m_client, this);
    m_upload = new IG::UploadEndpoint(m_client, this);

    // Create password encryptor and link it with session
    m_passwordEncryptor = new IG::PasswordEncryptor(this);
    m_passwordEncryptor->setSession(m_session);

    // Load existing session
    m_session->loadSession();
}

void Instagram::setupEndpointConnections() {
    // Account endpoint connections
    connect(m_account, &IG::AccountEndpoint::profilePrivateReady, this,
            &Instagram::setProfilePrivate);
    connect(m_account, &IG::AccountEndpoint::profilePublicReady, this,
            &Instagram::setProfilePublic);
    connect(m_account, &IG::AccountEndpoint::profilePictureRemoved, this,
            &Instagram::profilePictureDeleted);
    connect(m_account, &IG::AccountEndpoint::currentUserReady, this,
            &Instagram::currentUserDataReady);
    connect(m_account, &IG::AccountEndpoint::profileEdited, this, &Instagram::editDataReady);
    connect(m_account, &IG::AccountEndpoint::passwordChanged, this,
            &Instagram::changePasswordDataReady);
    connect(m_account, &IG::AccountEndpoint::logoutReady, this, &Instagram::doLogout);
    connect(m_account, &IG::AccountEndpoint::error, this, &Instagram::error);

    // Media endpoint connections
    connect(m_media, &IG::MediaEndpoint::likeReady, this, &Instagram::likeDataReady);
    connect(m_media, &IG::MediaEndpoint::unlikeReady, this, &Instagram::unLikeDataReady);
    connect(m_media, &IG::MediaEndpoint::likedMediaReady, this, &Instagram::likedMediaDataReady);
    connect(m_media, &IG::MediaEndpoint::mediaLikersReady, this, &Instagram::mediaLikersDataReady);
    connect(m_media, &IG::MediaEndpoint::mediaInfoReady, this, &Instagram::mediaInfoReady);
    connect(m_media, &IG::MediaEndpoint::mediaEdited, this, &Instagram::mediaEdited);
    connect(m_media, &IG::MediaEndpoint::mediaDeleted, this, &Instagram::mediaDeleted);
    connect(m_media, &IG::MediaEndpoint::commentPosted, this, &Instagram::commentPosted);
    connect(m_media, &IG::MediaEndpoint::commentDeleted, this, &Instagram::commentDeleted);
    connect(m_media, &IG::MediaEndpoint::commentLiked, this, &Instagram::commentLiked);
    connect(m_media, &IG::MediaEndpoint::commentUnliked, this, &Instagram::commentUnliked);
    connect(m_media, &IG::MediaEndpoint::commentsReady, this, &Instagram::mediaCommentsDataReady);
    connect(m_media, &IG::MediaEndpoint::commentsEnabled, this,
            &Instagram::enableMediaCommentsDataReady);
    connect(m_media, &IG::MediaEndpoint::commentsDisabled, this,
            &Instagram::disableMediaCommentsDataReady);
    connect(m_media, &IG::MediaEndpoint::mediaSaved, this, &Instagram::saveMediaDataReady);
    connect(m_media, &IG::MediaEndpoint::mediaUnsaved, this, &Instagram::unsaveMediaDataReady);
    connect(m_media, &IG::MediaEndpoint::savedFeedReady, this, &Instagram::savedFeedDataReady);
    connect(m_media, &IG::MediaEndpoint::error, this, &Instagram::error);

    // Direct endpoint connections
    connect(m_direct, &IG::DirectEndpoint::inboxReady, this, &Instagram::inboxDataReady);
    connect(m_direct, &IG::DirectEndpoint::directThreadReady, this,
            &Instagram::directThreadDataReady);
    connect(m_direct, &IG::DirectEndpoint::pendingInboxReady, this,
            &Instagram::pendingInboxDataReady);
    connect(m_direct, &IG::DirectEndpoint::rankedRecipientsReady, this,
            &Instagram::rankedRecipientsDataReady);
    connect(m_direct, &IG::DirectEndpoint::threadMarkedSeen, this,
            &Instagram::markThreadSeenDataReady);
    connect(m_direct, &IG::DirectEndpoint::messageReady, this, &Instagram::directMessageDataReady);
    connect(m_direct, &IG::DirectEndpoint::likeReady, this, &Instagram::directLikeDataReady);
    connect(m_direct, &IG::DirectEndpoint::shareReady, this, &Instagram::directShareDataReady);
    connect(m_direct, &IG::DirectEndpoint::error, this, &Instagram::error);

    // Feed endpoint connections
    connect(m_feed, &IG::FeedEndpoint::timelineFeedReady, this, &Instagram::timelineFeedDataReady);
    connect(m_feed, &IG::FeedEndpoint::userFeedReady, this, &Instagram::userFeedDataReady);
    connect(m_feed, &IG::FeedEndpoint::exploreFeedReady, this, &Instagram::exploreFeedDataReady);
    connect(m_feed, &IG::FeedEndpoint::suggestionsReady, this,
            &Instagram::suggestionsFeedDataReady);
    connect(m_feed, &IG::FeedEndpoint::error, this, &Instagram::error);

    // People endpoint connections
    connect(m_people, &IG::PeopleEndpoint::infoByIdReady, this, &Instagram::infoByIdDataReady);
    connect(m_people, &IG::PeopleEndpoint::infoByNameReady, this, &Instagram::infoByNameDataReady);
    connect(m_people, &IG::PeopleEndpoint::recentActivityReady, this,
            &Instagram::recentActivityInboxDataReady);
    connect(m_people, &IG::PeopleEndpoint::followingReady, this, &Instagram::followingDataReady);
    connect(m_people, &IG::PeopleEndpoint::followersReady, this, &Instagram::followersDataReady);
    connect(m_people, &IG::PeopleEndpoint::friendshipReady, this, &Instagram::friendshipDataReady);
    connect(m_people, &IG::PeopleEndpoint::followReady, this, &Instagram::followDataReady);
    connect(m_people, &IG::PeopleEndpoint::unfollowReady, this, &Instagram::unfollowDataReady);
    connect(m_people, &IG::PeopleEndpoint::favoriteReady, this, &Instagram::favoriteDataReady);
    connect(m_people, &IG::PeopleEndpoint::unfavoriteReady, this, &Instagram::unFavoriteDataReady);
    connect(m_people, &IG::PeopleEndpoint::blockReady, this, &Instagram::blockDataReady);
    connect(m_people, &IG::PeopleEndpoint::unblockReady, this, &Instagram::unBlockDataReady);
    connect(m_people, &IG::PeopleEndpoint::pendingFriendshipsReady, this,
            &Instagram::pendingFriendshipsDataReady);
    connect(m_people, &IG::PeopleEndpoint::approveFriendshipReady, this,
            &Instagram::approveFriendshipDataReady);
    connect(m_people, &IG::PeopleEndpoint::rejectFriendshipReady, this,
            &Instagram::rejectFriendshipDataReady);
    connect(m_people, &IG::PeopleEndpoint::autocompleteUserListReady, this,
            &Instagram::autocompleteUserListDataReady);
    connect(m_people, &IG::PeopleEndpoint::blockedUserListReady, this,
            &Instagram::blockedUserListDataReady);
    connect(m_people, &IG::PeopleEndpoint::searchUserReady, this, &Instagram::searchUserDataReady);
    connect(m_people, &IG::PeopleEndpoint::suggestedUserReady, this,
            &Instagram::suggestedUserDataReady);
    connect(m_people, &IG::PeopleEndpoint::error, this, &Instagram::error);

    // Story endpoint connections
    connect(m_story, &IG::StoryEndpoint::reelsTrayFeedReady, this,
            &Instagram::reelsTrayFeedDataReady);
    connect(m_story, &IG::StoryEndpoint::userReelsMediaFeedReady, this,
            &Instagram::userReelsMediaFeedDataReady);
    connect(m_story, &IG::StoryEndpoint::reelsMediaFeedReady, this,
            &Instagram::reelsMediaFeedDataReady);
    connect(m_story, &IG::StoryEndpoint::storyMediaSeenReady, this,
            &Instagram::markStoryMediaSeenDataReady);
    connect(m_story, &IG::StoryEndpoint::userHighlightFeedReady, this,
            &Instagram::userHighlightFeedDataReady);
    connect(m_story, &IG::StoryEndpoint::error, this, &Instagram::error);

    // Hashtag endpoint connections
    connect(m_hashtag, &IG::HashtagEndpoint::tagSectionFeedReady, this,
            &Instagram::tagSectionFeedDataReady);
    connect(m_hashtag, &IG::HashtagEndpoint::searchTagsReady, this,
            &Instagram::searchTagsDataReady);
    connect(m_hashtag, &IG::HashtagEndpoint::error, this, &Instagram::error);

    // Location endpoint connections
    connect(m_location, &IG::LocationEndpoint::locationSectionFeedReady, this,
            &Instagram::locationSectionFeedDataReady);
    connect(m_location, &IG::LocationEndpoint::searchLocationReady, this,
            &Instagram::searchLocationDataReady);
    connect(m_location, &IG::LocationEndpoint::error, this, &Instagram::error);

    // Search endpoint connections
    connect(m_search, &IG::SearchEndpoint::recentSearchesReady, this,
            &Instagram::recentSearchesDataReady);
    connect(m_search, &IG::SearchEndpoint::searchPlacesReady, this,
            &Instagram::searchPlacesDataReady);
    connect(m_search, &IG::SearchEndpoint::error, this, &Instagram::error);

    // Usertag endpoint connections
    connect(m_usertag, &IG::UsertagEndpoint::userTagsReady, this, &Instagram::userTagsDataReady);
    connect(m_usertag, &IG::UsertagEndpoint::selfTagRemoved, this, &Instagram::removeSelftagDone);
    connect(m_usertag, &IG::UsertagEndpoint::error, this, &Instagram::error);

    // Upload endpoint connections
    connect(m_upload, &IG::UploadEndpoint::imageConfigured, this,
            &Instagram::imageConfigureDataReady);
    connect(m_upload, &IG::UploadEndpoint::videoConfigured, this,
            &Instagram::videoConfigureDataReady);
    connect(m_upload, &IG::UploadEndpoint::uploadProgress, this,
            &Instagram::imageUploadProgressDataReady);
    connect(m_upload, &IG::UploadEndpoint::profilePictureChanged, this,
            &Instagram::profilePictureChanged);
    connect(m_upload, &IG::UploadEndpoint::error, this, &Instagram::error);
    connect(m_upload, &IG::UploadEndpoint::error, this, &Instagram::uploadFailed);

    // Error handling from API client
    connect(m_client, &IG::ApiClient::error, this, &Instagram::error);
}

QString Instagram::photos_path() {
    return m_session->photosPath().absolutePath();
}

// ============================================================================
// Authentication
// ============================================================================

void Instagram::login(bool force, QString username, QString password, bool set) {
    if (set) {
        m_session->setUsername(username);
        m_session->setPassword(password);
    }

    if (!force) {
        // Try to use existing session
        if (m_session->isLoggedIn()) {
            QVariant empty;
            emit profileConnected(empty);
            return;
        } else {
            emit profileConnectedFail();
            // Continue to login
        }
    }

    // Fetch headers first, then do pre-login flow
    m_account->fetchHeaders();

    connect(
        m_account, &IG::AccountEndpoint::headersReady, this,
        [this](const QVariant &) {
            // Extract CSRF token from cookies after fetchHeaders
            QString csrfToken = m_cookies->extractCsrfToken();
            if (!csrfToken.isEmpty()) {
                m_session->setCsrfToken(csrfToken);
            }
            doPreLoginFlow();
        },
        Qt::UniqueConnection);
}

void Instagram::doPreLoginFlow() {
    // Ensure we have a CSRF token before making any requests
    // Modern Instagram may not send cookies, so we generate one if needed
    m_session->ensureCsrfToken();

    // Call pre-login flow first (launcher/sync)
    m_account->preLoginFlow(m_session->uuid(), m_session->phoneId(), m_session->deviceId());

    // Connect to proceed with password encryption after pre-login
    connect(
        m_account, &IG::AccountEndpoint::preLoginFlowReady, this,
        [this](const QVariant &) {
            // Encrypt password and then login
            m_passwordEncryptor->encryptPassword(m_session->password(),
                                                 [this](const QString & encryptedPassword) {
                                                     if (encryptedPassword.isEmpty()) {
                                                         emit error("Password encryption failed");
                                                         emit profileConnectedFail();
                                                         return;
                                                     }
                                                     doLogin(encryptedPassword);
                                                 });
        },
        Qt::UniqueConnection);
}

void Instagram::doLogin(const QString & encryptedPassword) {
    // Generate jazoest from phone_id
    QString jazoest = IG::PasswordEncryptor::generateJazoest(m_session->phoneId());

    // Call the new login with all required parameters
    m_account->login(m_session->username(), encryptedPassword, m_session->uuid(),
                     m_session->deviceId(), m_session->phoneId(), m_session->advertisingId(),
                     jazoest);

    connect(
        m_account, &IG::AccountEndpoint::loginReady, this,
        [this](const QVariant & response) { handleLoginResponse(response); }, Qt::UniqueConnection);
}

void Instagram::handleLoginResponse(const QVariant & response) {
    QJsonDocument doc = QJsonDocument::fromJson(response.toString().toUtf8());
    QJsonObject obj = doc.object();

    if (obj["status"].toString() == "fail") {
        if (obj.contains("two_factor_required") && obj["two_factor_required"].toBool()) {
            emit twoFactorRequired(obj);
        } else {
            emit error(obj["message"].toString());
            emit profileConnectedFail();

            if (obj["message"].toString() == "challenge_required") {
                emit challengeRequired(obj["challenge"].toObject());
            }
        }
    } else {
        // Login successful
        QJsonObject user = obj["logged_in_user"].toObject();
        m_isLoggedIn = true;

        QString userId = QString("%1").arg(user["pk"].toDouble(), 0, 'f', 0);
        m_session->setUserId(userId);
        m_session->setLoggedIn(true);

        // Save cookies and extract CSRF token
        m_cookies->saveCookies();

        // Extract CSRF token from cookies
        QString csrfToken = m_cookies->extractCsrfToken();

        // If no CSRF token in cookies, try to get from the pre-login flow
        // The token should have been set during fetchHeaders or qe/sync
        if (csrfToken.isEmpty()) {
            csrfToken = m_session->csrfToken();
        }

        // If still no CSRF token, generate one (following instagrapi approach)
        // Modern Instagram doesn't always send cookies, so we generate a token
        if (csrfToken.isEmpty()) {
            m_session->ensureCsrfToken();
            csrfToken = m_session->csrfToken();
        } else {
            m_session->setCsrfToken(csrfToken);
        }

        m_session->saveSession();

        // Sync features (non-blocking, errors are logged but not propagated)
        m_account->syncFeatures(userId, m_session->password());

        emit profileConnected(response);
    }
}

void Instagram::logout() {
    m_account->logout(m_session->uuid(), m_session->deviceId(), m_session->csrfToken());
    m_session->clearSession();
    m_cookies->clearCookies();
    m_isLoggedIn = false;
}

void Instagram::confirm2Factor(QString code, QString identifier, QString method) {
    // Updated to use phoneId instead of password (modern Instagram API)
    m_account->confirm2Factor(code, identifier, method, m_session->username(), m_session->phoneId(),
                              m_session->uuid(), m_session->deviceId(), m_session->csrfToken());

    connect(
        m_account, &IG::AccountEndpoint::twoFactorLoginReady, this,
        [this](const QVariant & response) { handleLoginResponse(response); }, Qt::UniqueConnection);
}

void Instagram::setUsername(QString username) {
    m_session->setUsername(username);
}

void Instagram::setPassword(QString password) {
    m_session->setPassword(password);
}

QString Instagram::getUsernameId() {
    return m_session->userId();
}

QString Instagram::getPhoneId() {
    return m_session->phoneId();
}

void Instagram::registerPush(QString token) {
    // Generate a random family_device_id (UUID v4)
    QString familyDeviceId = QUuid::createUuid().toString();
    familyDeviceId = familyDeviceId.mid(1, familyDeviceId.length() - 2);

    auto request = IG::RequestBuilder::post("push/register/")
                       .param("device_type", "android_mqtt")
                       .param("is_main_push_channel", "true")
                       .param("device_sub_type", "2")
                       .param("device_token", token)
                       .param("guid", m_session->uuid())
                       .param("uuid", m_session->uuid())
                       .param("users", m_session->userId())
                       .param("family_device_id", familyDeviceId)
                       .authenticated()
                       .unsigned_()
                       .build();

    m_client->execute(request, [this](const IG::Response & response) {
        if (response.ok()) {
            emit pushRegistered(response.toVariant());
        } else {
            qWarning() << "Instagram: push/register/ failed:" << response.errorMessage();
            emit error(response.errorMessage());
        }
    });
}

// ============================================================================
// Account
// ============================================================================

void Instagram::setPrivateAccount() {
    m_account->setPrivateAccount();
}

void Instagram::setPublicAccount() {
    m_account->setPublicAccount();
}

void Instagram::changeProfilePicture(QString path) {
    if (QFile::exists(path)) {
        m_upload->changeProfilePicture(path);
    } else {
        emit error("Profile picture file not found");
    }
}

void Instagram::removeProfilePicture() {
    m_account->removeProfilePicture();
}

void Instagram::getCurrentUser() {
    m_account->getCurrentUser();
}

void Instagram::editProfile(QString url, QString phone, QString first_name, QString biography,
                            QString email, bool gender) {
    getCurrentUser();
    m_account->editProfile(url, phone, first_name, biography, email, gender, m_session->username());
}

void Instagram::changePassword(QString oldPassword, QString newPassword) {
    m_passwordEncryptor->encryptPassword(oldPassword, [this, newPassword](const QString & encOld) {
        if (encOld.isEmpty()) {
            emit error("Password encryption failed");
            return;
        }
        QTimer::singleShot(0, this, [this, encOld, newPassword]() {
            m_passwordEncryptor->encryptPassword(newPassword, [this, encOld](const QString & encNew) {
                if (encNew.isEmpty()) {
                    emit error("Password encryption failed");
                    return;
                }
                m_account->changePassword(encOld, encNew);
            });
        });
    });
}

// ============================================================================
// Direct
// ============================================================================

void Instagram::getInbox(QString cursorId) {
    m_direct->getInbox(cursorId);
}

void Instagram::getDirectThread(QString threadId, QString cursorId) {
    m_direct->getDirectThread(threadId, cursorId);
}

void Instagram::getPendingInbox() {
    m_direct->getPendingInbox();
}

void Instagram::getRankedRecipients(QString query) {
    m_direct->getRankedRecipients(query);
}

void Instagram::markThreadSeen(QString threadId, QString threadItemId) {
    m_direct->markThreadSeen(threadId, threadItemId, m_session->uuid(), m_session->csrfToken());
}

void Instagram::directMessage(QString recipients, QString text, QString thread_id) {
    m_direct->sendMessage(recipients, text, thread_id, m_session->uuid());
}

void Instagram::directLike(QString recipients, QString thread_id) {
    m_direct->sendLike(recipients, thread_id, m_session->uuid());
}

void Instagram::directShare(QString mediaId, QString recipients, QString text) {
    m_direct->shareMedia(mediaId, recipients, text, m_session->uuid());
}

// ============================================================================
// Discover/Feed
// ============================================================================

void Instagram::getExploreFeed(QString max_id) {
    // Generate a session ID for the explore feed
    QString sessionId = QUuid::createUuid().toString();
    sessionId = sessionId.mid(1, sessionId.length() - 2); // Remove braces
    m_feed->getExploreFeed(max_id, sessionId);
}

void Instagram::getSuggestions() {
    m_feed->getSuggestions(m_session->uuid(), m_session->csrfToken());
}

// ============================================================================
// FBSearch
// ============================================================================

void Instagram::recentSearches() {
    m_search->recentSearches();
}

void Instagram::searchPlaces(QString query) {
    m_search->searchPlaces(query, m_session->rankToken());
}

// ============================================================================
// Location
// ============================================================================

void Instagram::getLocationSectionFeed(QString locationId, QString tab, int page,
                                       QStringList nextMediaIds, QString max_id) {
    m_location->getLocationSectionFeed(locationId, tab, page, nextMediaIds, max_id);
}

void Instagram::searchLocation(QString lat, QString lng, QString query) {
    m_location->searchLocation(lat, lng, query, m_session->rankToken());
}

// ============================================================================
// Hashtag
// ============================================================================

void Instagram::getTagSectionFeed(QString tag, QString tab, int page, QStringList nextMediaIds,
                                  QString max_id) {
    m_hashtag->getTagSectionFeed(tag, tab, page, nextMediaIds, max_id);
}

void Instagram::searchTags(QString tag) {
    m_hashtag->searchTags(tag, m_session->rankToken());
}

// ============================================================================
// Highlight
// ============================================================================

void Instagram::getUserHighlightFeed(QString userId) {
    m_story->getUserHighlightFeed(userId);
}

// ============================================================================
// Media
// ============================================================================

void Instagram::getInfoMedia(QString mediaId) {
    m_media->getInfo(mediaId);
}

void Instagram::editMedia(QString mediaId, QString captionText, QString mediaType) {
    m_media->edit(mediaId, captionText, mediaType);
}

void Instagram::deleteMedia(QString mediaId, QString mediaType) {
    m_media->deleteMedia(mediaId, mediaType);
}

void Instagram::like(QString mediaId, QString module) {
    m_media->like(mediaId, module);
}

void Instagram::unLike(QString mediaId, QString module) {
    m_media->unlike(mediaId, module);
}

void Instagram::comment(QString mediaId, QString commentText, QString replyCommentId,
                        QString module) {
    m_media->postComment(mediaId, commentText, replyCommentId, module);
}

void Instagram::deleteComment(QString mediaId, QString commentId) {
    m_media->deleteComment(mediaId, commentId);
}

void Instagram::likeComment(QString commentId) {
    m_media->likeComment(commentId);
}

void Instagram::unlikeComment(QString commentId) {
    m_media->unlikeComment(commentId);
}

void Instagram::getComments(QString mediaId, QString max_id) {
    m_media->getComments(mediaId, max_id);
}

void Instagram::getLikedMedia(QString max_id) {
    m_media->getLikedMedia(max_id);
}

void Instagram::getMediaLikers(QString mediaId) {
    m_media->getMediaLikers(mediaId);
}

void Instagram::enableMediaComments(QString mediaId) {
    m_media->enableComments(mediaId);
}

void Instagram::disableMediaComments(QString mediaId) {
    m_media->disableComments(mediaId);
}

void Instagram::saveMedia(QString mediaId) {
    m_media->save(mediaId);
}

void Instagram::unsaveMedia(QString mediaId) {
    m_media->unsave(mediaId);
}

void Instagram::getSavedFeed(QString max_id) {
    m_media->getSavedFeed(max_id);
}

// ============================================================================
// People
// ============================================================================

void Instagram::getInfoById(QString userId) {
    m_people->getInfoById(userId, m_session->deviceId());
}

void Instagram::getInfoByName(QString username) {
    m_people->getInfoByName(username);
}

void Instagram::getRecentActivityInbox() {
    m_people->getRecentActivityInbox();
}

void Instagram::getFollowing(QString userId, QString max_id, QString searchQuery) {
    m_people->getFollowing(userId, max_id, searchQuery, m_session->rankToken());
}

void Instagram::getFollowers(QString userId, QString max_id, QString searchQuery) {
    m_people->getFollowers(userId, max_id, searchQuery, m_session->rankToken());
}

void Instagram::getFriendship(QString userId) {
    m_people->getFriendship(userId);
}

void Instagram::getSuggestedUser(QString userId) {
    m_people->getSuggestedUser(userId);
}

void Instagram::getAutocompleteUserList() {
    m_people->getAutocompleteUserList();
}

void Instagram::getBlockedUserList() {
    m_people->getBlockedUserList();
}

void Instagram::favorite(QString userId) {
    m_people->favorite(userId);
}

void Instagram::unFavorite(QString userId) {
    m_people->unfavorite(userId);
}

void Instagram::follow(QString userId) {
    m_people->follow(userId);
}

void Instagram::unFollow(QString userId) {
    m_people->unfollow(userId);
}

void Instagram::block(QString userId) {
    m_people->block(userId);
}

void Instagram::unBlock(QString userId) {
    m_people->unblock(userId);
}

void Instagram::getPendingFriendships() {
    m_people->getPendingFriendships();
}

void Instagram::approveFriendship(QString userId) {
    m_people->approveFriendship(userId);
}

void Instagram::rejectFriendship(QString userId) {
    m_people->rejectFriendship(userId);
}

void Instagram::searchUser(QString query) {
    m_people->searchUser(query, m_session->rankToken());
}

// ============================================================================
// Story
// ============================================================================

void Instagram::getReelsTrayFeed() {
    m_story->getReelsTrayFeed();
}

void Instagram::getUserReelsMediaFeed(QString userId) {
    m_story->getUserReelsMediaFeed(userId);
}

void Instagram::markStoryMediaSeen(QString reels) {
    m_story->markStoryMediaSeen(reels);
}

void Instagram::getReelsMediaFeed(QString id) {
    m_story->getReelsMediaFeed(id);
}

// ============================================================================
// Timeline
// ============================================================================

void Instagram::getTimelineFeed(QString max_id, QString seen_posts, bool pullToRefresh) {
    m_feed->getTimelineFeed(max_id, seen_posts, pullToRefresh, m_session->uuid(),
                            m_session->deviceId(), m_session->csrfToken());
}

void Instagram::getUserFeed(QString userID, QString max_id, QString minTimestamp) {
    m_feed->getUserFeed(userID, max_id, minTimestamp, m_session->rankToken());
}

// ============================================================================
// Usertag
// ============================================================================

void Instagram::getUserTags(QString userId, QString max_id, QString minTimestamp) {
    m_usertag->getUserTags(userId, max_id, minTimestamp, m_session->rankToken());
}

void Instagram::removeSelftag(QString mediaId) {
    m_usertag->removeSelfTag(mediaId);
}

// ============================================================================
// Image upload
// ============================================================================

void Instagram::postImage(QString path, QString caption, QVariantMap location, QString upload_id,
                          QString disableComments) {
    m_upload->postImage(path, caption, location, upload_id, disableComments);
}

void Instagram::postVideo(QString videoPath, QString coverPath, int width, int height,
                          qint64 durationMs, QString caption, QVariantMap location,
                          QString disableComments) {
    m_upload->postVideo(videoPath, coverPath, width, height, durationMs, caption, location,
                        disableComments);
}

// ============================================================================
// Network access
// ============================================================================

void Instagram::setNetworkAccessManager(QNetworkAccessManager * nam) {
    m_client->setNetworkManager(nam);
}

QNetworkAccessManager * Instagram::networkAccessManager() const {
    return m_client->networkManager();
}
