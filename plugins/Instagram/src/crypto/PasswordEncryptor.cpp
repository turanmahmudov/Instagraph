#include "PasswordEncryptor.h"
#include "../session/SessionManager.h"
#include "../utils/Constants.h"
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <QRandomGenerator>
#include <QUrlQuery>

// For RSA/AES encryption we need OpenSSL
#include <openssl/rsa.h>
#include <openssl/pem.h>
#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/err.h>

namespace IG {

PasswordEncryptor::PasswordEncryptor(QObject* parent)
    : QObject(parent)
    , m_network(new QNetworkAccessManager(this))
    , m_session(nullptr)
{
    connect(m_network, &QNetworkAccessManager::finished,
            this, &PasswordEncryptor::onPublicKeysReceived);
}

PasswordEncryptor::~PasswordEncryptor() {
}

QString PasswordEncryptor::generateJazoest(const QString& phoneId) {
    // Sum of ASCII values of all characters in phoneId
    int sum = 0;
    for (const QChar& c : phoneId) {
        sum += c.unicode();
    }
    return QString("2%1").arg(sum);
}

QNetworkRequest PasswordEncryptor::buildRequest() {
    QNetworkRequest request(QUrl("https://i.instagram.com/api/v1/qe/sync/"));
    
    // Set all the proper Instagram headers (matching ApiClient)
    request.setRawHeader("User-Agent", Constants::userAgent());
    request.setRawHeader("X-IG-App-ID", Constants::appId().toUtf8());
    request.setRawHeader("X-IG-Capabilities", Constants::igCapabilities());
    request.setRawHeader("X-IG-Connection-Type", "WIFI");
    request.setRawHeader("X-IG-Connection-Speed", "-1kbps");
    request.setRawHeader("X-IG-Bandwidth-Speed-KBPS", "-1.000");
    request.setRawHeader("X-IG-Bandwidth-TotalBytes-B", "0");
    request.setRawHeader("X-IG-Bandwidth-TotalTime-MS", "0");
    request.setRawHeader("X-Bloks-Version-Id", Constants::bloksVersionId().toUtf8());
    request.setRawHeader("X-Bloks-Is-Layout-RTL", "false");
    request.setRawHeader("X-Bloks-Is-Panorama-Enabled", "true");
    request.setRawHeader("X-FB-HTTP-Engine", "Liger");
    request.setRawHeader("X-FB-Client-IP", "True");
    request.setRawHeader("X-FB-Server-Cluster", "True");
    request.setRawHeader("Accept-Language", "en-US");
    request.setRawHeader("Accept-Encoding", "gzip, deflate");
    request.setRawHeader("Host", "i.instagram.com");
    request.setRawHeader("Connection", "keep-alive");
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
    
    // Session-specific headers
    if (m_session) {
        request.setRawHeader("X-IG-Device-ID", m_session->uuid().toUtf8());
        request.setRawHeader("X-IG-Family-Device-ID", m_session->phoneId().toUtf8());
        request.setRawHeader("X-IG-Android-ID", m_session->deviceId().toUtf8());
        request.setRawHeader("X-IG-Timezone-Offset", QString::number(Constants::timezoneOffset()).toUtf8());
        request.setRawHeader("X-IG-App-Locale", Constants::locale().toUtf8());
        request.setRawHeader("X-IG-Device-Locale", Constants::locale().toUtf8());
        request.setRawHeader("X-IG-Mapped-Locale", Constants::locale().toUtf8());
        request.setRawHeader("X-IG-App-Startup-Country", Constants::country().toUtf8());
        request.setRawHeader("IG-INTENDED-USER-ID", "0");
        
        // Generate a pigeon session ID
        QString pigeonSessionId = QString("UFS-%1-0").arg(m_session->uuid());
        request.setRawHeader("X-Pigeon-Session-Id", pigeonSessionId.toUtf8());
        request.setRawHeader("X-Pigeon-Rawclienttime", QString::number(QDateTime::currentMSecsSinceEpoch() / 1000.0, 'f', 3).toUtf8());
    }
    
    return request;
}

QByteArray PasswordEncryptor::buildRequestBody() {
    // Build signed body for qe/sync endpoint
    QJsonObject data;
    if (m_session) {
        data["id"] = m_session->uuid();
    } else {
        data["id"] = "";
    }
    data["server_config_retrieval"] = "1";
    
    QJsonDocument doc(data);
    QString jsonStr = QString::fromUtf8(doc.toJson(QJsonDocument::Compact));
    
    // Instagram uses "SIGNATURE.json" format with literal "SIGNATURE"
    QString signedBody = QString("SIGNATURE.%1").arg(jsonStr);
    
    return QString("signed_body=%1").arg(QString::fromUtf8(QUrl::toPercentEncoding(signedBody))).toUtf8();
}

void PasswordEncryptor::encryptPassword(const QString& password,
                                        std::function<void(const QString&)> callback) {
    m_pendingPassword = password;
    m_callback = callback;
    
    QNetworkRequest request = buildRequest();
    
    // instagrapi uses GET request to fetch encryption keys
    m_network->get(request);
}

void PasswordEncryptor::onPublicKeysReceived(QNetworkReply* reply) {
    reply->deleteLater();
    
    // Get encryption keys from response headers
    // Instagram sometimes returns the keys even with a 400 response
    QString keyIdStr = reply->rawHeader("ig-set-password-encryption-key-id");
    QString publicKey = reply->rawHeader("ig-set-password-encryption-pub-key");
    
    if (keyIdStr.isEmpty() || publicKey.isEmpty()) {
        // Fallback: Use a recent known public key
        // This is a temporary workaround - in production, we should always get fresh keys
        // Key ID 251 and its public key (this may need to be updated periodically)
        keyIdStr = "251";
        publicKey = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUFxMlA4ckVaOEliUW1WdVdmYTdNUgp5bTBTOWhIRlNjYVdwTHB0V0x3bGcvNnlxQ1pwQ3M3cjUrSHFLZTdHK2RXQ25kRy9hblB5ZHZoUDhnMUxtMDBUCjJ3SkVqdXJHMldwL3NWU1Y1QWZDUTM5WjNXdTlMNkhlQmtxMmhZRkV2ZzJIY2R0eGlqYkdjWTJka0ZEWGFFNE4KNFptRkZVY3kzTjg0blhIOXcyWWozRmV0Q0tyeFlMNjkxUTZwM0NHdWRsMEZNdW5QZzhGK1duZ2xvM2hBRUVNSQplVkdEeXh0Rkx4N2Y5TFo4Smd3cHRySWhwc3l4NGNLRE9Nc0xNQTMzNTRJNUJ6bzJ0YkNHMFFIRnN1R2NZMEs1ClRYVXI5YmFCam82N0NLV0JYNDY3NEg1dEF0dEJ0T0M0Mm1Kck9oUldONElZajVRSTk1TE1wYjEvWkRFR0xxVXIKR1FJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg==";
    }
    
    int keyId = keyIdStr.toInt();
    QString encryptedPassword = doEncrypt(m_pendingPassword, keyId, publicKey);
    
    if (encryptedPassword.isEmpty()) {
        emit encryptionFailed("Encryption failed");
        if (m_callback) {
            m_callback(QString());
        }
    } else {
        emit encryptionComplete(encryptedPassword);
        if (m_callback) {
            m_callback(encryptedPassword);
        }
    }
}

QString PasswordEncryptor::doEncrypt(const QString& password, int keyId, const QString& publicKey) {
    // Decode base64 public key
    QByteArray decodedKey = QByteArray::fromBase64(publicKey.toUtf8());
    
    // Generate random session key (32 bytes) and IV (12 bytes for GCM)
    unsigned char sessionKey[32];
    unsigned char iv[12];
    RAND_bytes(sessionKey, 32);
    RAND_bytes(iv, 12);
    
    // Get current timestamp
    QString timestamp = QString::number(QDateTime::currentSecsSinceEpoch());
    QByteArray timestampBytes = timestamp.toUtf8();
    
    // Load RSA public key
    BIO* bio = BIO_new_mem_buf(decodedKey.data(), decodedKey.size());
    if (!bio) {
        return QString();
    }
    
    RSA* rsa = PEM_read_bio_RSA_PUBKEY(bio, nullptr, nullptr, nullptr);
    BIO_free(bio);
    
    if (!rsa) {
        return QString();
    }
    
    // RSA encrypt the session key using PKCS1 v1.5 padding
    int rsaSize = RSA_size(rsa);
    QByteArray rsaEncrypted(rsaSize, 0);
    
    int rsaLen = RSA_public_encrypt(32, sessionKey, 
                                     reinterpret_cast<unsigned char*>(rsaEncrypted.data()),
                                     rsa, RSA_PKCS1_PADDING);
    RSA_free(rsa);
    
    if (rsaLen < 0) {
        return QString();
    }
    rsaEncrypted.resize(rsaLen);
    
    // AES-GCM encrypt the password
    QByteArray passwordBytes = password.toUtf8();
    QByteArray aesEncrypted(passwordBytes.size() + 16, 0); // +16 for potential padding
    QByteArray tag(16, 0);
    
    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) {
        return QString();
    }
    
    int len = 0;
    int ciphertextLen = 0;
    
    // Initialize encryption
    if (EVP_EncryptInit_ex(ctx, EVP_aes_256_gcm(), nullptr, nullptr, nullptr) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    
    // Set IV length
    EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_SET_IVLEN, 12, nullptr);
    
    // Initialize key and IV
    if (EVP_EncryptInit_ex(ctx, nullptr, nullptr, sessionKey, iv) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    
    // Add AAD (timestamp)
    if (EVP_EncryptUpdate(ctx, nullptr, &len, 
                          reinterpret_cast<const unsigned char*>(timestampBytes.data()),
                          timestampBytes.size()) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    
    // Encrypt password
    if (EVP_EncryptUpdate(ctx, reinterpret_cast<unsigned char*>(aesEncrypted.data()), &len,
                          reinterpret_cast<const unsigned char*>(passwordBytes.data()),
                          passwordBytes.size()) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    ciphertextLen = len;
    
    // Finalize
    if (EVP_EncryptFinal_ex(ctx, reinterpret_cast<unsigned char*>(aesEncrypted.data()) + len, &len) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    ciphertextLen += len;
    aesEncrypted.resize(ciphertextLen);
    
    // Get tag
    if (EVP_CIPHER_CTX_ctrl(ctx, EVP_CTRL_GCM_GET_TAG, 16, tag.data()) != 1) {
        EVP_CIPHER_CTX_free(ctx);
        return QString();
    }
    
    EVP_CIPHER_CTX_free(ctx);
    
    // Build payload:
    // 0x01 (1 byte) + keyId (1 byte) + iv (12 bytes) + rsaSize (2 bytes LE) + rsaEncrypted + tag (16 bytes) + aesEncrypted
    QByteArray payload;
    payload.append('\x01');  // Version byte
    payload.append(static_cast<char>(keyId));  // Key ID
    payload.append(reinterpret_cast<const char*>(iv), 12);  // IV
    
    // RSA encrypted size as 2 bytes little endian
    quint16 rsaSizeLE = static_cast<quint16>(rsaEncrypted.size());
    payload.append(static_cast<char>(rsaSizeLE & 0xFF));
    payload.append(static_cast<char>((rsaSizeLE >> 8) & 0xFF));
    
    payload.append(rsaEncrypted);  // RSA encrypted session key
    payload.append(tag);  // GCM tag
    payload.append(aesEncrypted);  // AES encrypted password
    
    // Base64 encode
    QString base64Payload = QString::fromLatin1(payload.toBase64());
    
    // Format: #PWD_INSTAGRAM:4:timestamp:base64payload
    return QString("#PWD_INSTAGRAM:4:%1:%2").arg(timestamp).arg(base64Payload);
}

} // namespace IG
