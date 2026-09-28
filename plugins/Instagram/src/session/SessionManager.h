#ifndef INSTAGRAM_SESSIONMANAGER_H
#define INSTAGRAM_SESSIONMANAGER_H

#include <QDir>
#include <QObject>
#include <QString>
#include <QVariantMap>

namespace IG {

class SessionManager : public QObject {
    Q_OBJECT
public:
    explicit SessionManager(QObject * parent = nullptr);
    ~SessionManager();

    // Getters
    bool isLoggedIn() const {
        return m_isLoggedIn;
    }
    QString userId() const {
        return m_userId;
    }
    QString username() const {
        return m_username;
    }
    QString password() const {
        return m_password;
    }
    QString csrfToken() const {
        return m_csrfToken;
    }
    QString uuid() const {
        return m_uuid;
    }
    QString deviceId() const {
        return m_deviceId;
    }
    QString phoneId() const {
        return m_phoneId;
    }
    QString advertisingId() const {
        return m_advertisingId;
    }
    QString rankToken() const {
        return m_rankToken;
    }
    QString authorizationHeader() const {
        return m_authorizationHeader;
    }
    QDir dataPath() const {
        return m_dataPath;
    }
    QDir photosPath() const {
        return m_photosPath;
    }

    // Setters
    void setUsername(const QString & username);
    void setPassword(const QString & password);
    void setUserId(const QString & userId);
    void setCsrfToken(const QString & token);
    void setLoggedIn(bool loggedIn);
    void setAuthorizationHeader(const QString & header);

    // Authenticated params for API requests (SOLID: Single Responsibility)
    QVariantMap authenticatedParams() const;

    // Session persistence
    void saveSession();
    void loadSession();
    void clearSession();

    // Device ID generation
    QString generateDeviceId();
    void regenerateUuid();

    // CSRF token generation (fallback when Instagram doesn't send cookies)
    static QString generateCsrfToken();
    void ensureCsrfToken();

signals:
    void sessionChanged();
    void loginStateChanged(bool loggedIn);

private:
    void updateRankToken();
    void initializePaths();
    void initializeUuid();

    bool m_isLoggedIn;
    QString m_userId;
    QString m_username;
    QString m_password;
    QString m_csrfToken;
    QString m_uuid;
    QString m_deviceId;
    QString m_phoneId;
    QString m_advertisingId;
    QString m_rankToken;
    QString m_authorizationHeader;
    QDir m_dataPath;
    QDir m_photosPath;
};

} // namespace IG

#endif // INSTAGRAM_SESSIONMANAGER_H
