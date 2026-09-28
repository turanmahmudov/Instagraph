#ifndef INSTAGRAM_ACCOUNTENDPOINT_H
#define INSTAGRAM_ACCOUNTENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all account-related API operations.
 *
 * This endpoint manages:
 * - Login/logout and authentication
 * - Two-factor authentication
 * - Profile privacy settings
 * - Profile picture management
 * - Profile editing

 */
class AccountEndpoint : public QObject {
    Q_OBJECT

public:
    explicit AccountEndpoint(ApiClient * client, QObject * parent = nullptr);

    // Authentication
    void fetchHeaders();

    /**
     * Pre-login flow: calls launcher/sync endpoint before login
     * This is required before calling login()
     */
    void preLoginFlow(const QString & uuid, const QString & phoneId, const QString & deviceId);

    /**
     * Modern login with encrypted password and all required parameters
     * Based on instagrapi implementation
     */
    void login(const QString & username, const QString & encPassword, const QString & uuid,
               const QString & deviceId, const QString & phoneId, const QString & advertisingId,
               const QString & jazoest);

    void confirm2Factor(const QString & code, const QString & identifier, const QString & method,
                        const QString & username, const QString & phoneId, const QString & uuid,
                        const QString & deviceId, const QString & csrfToken);
    void logout(const QString & uuid, const QString & deviceId, const QString & csrfToken);

    // Profile privacy
    void setPrivateAccount();
    void setPublicAccount();

    // Profile picture
    void removeProfilePicture();

    // Profile data
    void getCurrentUser();
    void editProfile(const QString & url, const QString & phone, const QString & firstName,
                     const QString & biography, const QString & email, bool gender,
                     const QString & username);

    // Password
    void changePassword(const QString & encOldPassword, const QString & encNewPassword);

    // Username management
    void checkUsername(const QString & username, const QString & userId);

    // Feature sync (called after login)
    void syncFeatures(const QString & userId, const QString & password);

Q_SIGNALS:
    // Authentication signals
    void headersReady(const QVariant & answer);
    void preLoginFlowReady(const QVariant & answer);
    void loginReady(const QVariant & answer);
    void twoFactorLoginReady(const QVariant & answer);
    void logoutReady(const QVariant & answer);

    // Profile signals
    void profilePrivateReady(const QVariant & answer);
    void profilePublicReady(const QVariant & answer);
    void profilePictureRemoved(const QVariant & answer);
    void currentUserReady(const QVariant & answer);
    void profileEdited(const QVariant & answer);
    void usernameCheckReady(const QVariant & answer);
    void passwordChanged(const QVariant & answer);
    void featuresSynced(const QVariant & answer);

    void error(const QString & message);

private:
    ApiClient * m_client;
};

} // namespace IG

#endif // INSTAGRAM_ACCOUNTENDPOINT_H
