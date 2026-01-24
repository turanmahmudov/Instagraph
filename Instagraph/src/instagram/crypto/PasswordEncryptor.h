#ifndef INSTAGRAM_PASSWORD_ENCRYPTOR_H
#define INSTAGRAM_PASSWORD_ENCRYPTOR_H

#include <QString>
#include <QByteArray>
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <functional>

namespace IG {

class SessionManager;

/**
 * Handles Instagram password encryption using RSA + AES-GCM
 * Based on instagrapi's password encryption implementation
 */
class PasswordEncryptor : public QObject {
    Q_OBJECT
public:
    explicit PasswordEncryptor(QObject* parent = nullptr);
    ~PasswordEncryptor();

    /**
     * Set session manager for building proper headers
     */
    void setSession(SessionManager* session) { m_session = session; }

    /**
     * Fetch public keys from Instagram and then encrypt the password
     * @param password The plain text password
     * @param callback Called with encrypted password or empty string on error
     */
    void encryptPassword(const QString& password, 
                         std::function<void(const QString&)> callback);

    /**
     * Generate jazoest parameter from phone_id
     * @param phoneId The phone ID (UUID format)
     * @return jazoest string like "2xxxxx"
     */
    static QString generateJazoest(const QString& phoneId);

signals:
    void encryptionComplete(const QString& encryptedPassword);
    void encryptionFailed(const QString& error);

private slots:
    void onPublicKeysReceived(QNetworkReply* reply);

private:
    QString doEncrypt(const QString& password, int keyId, const QString& publicKey);
    QNetworkRequest buildRequest();
    QByteArray buildRequestBody();
    
    QNetworkAccessManager* m_network;
    SessionManager* m_session;
    QString m_pendingPassword;
    std::function<void(const QString&)> m_callback;
};

} // namespace IG

#endif // INSTAGRAM_PASSWORD_ENCRYPTOR_H
