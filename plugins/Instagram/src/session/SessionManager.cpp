#include "SessionManager.h"
#include <QCryptographicHash>
#include <QDateTime>
#include <QFile>
#include <QFileInfo>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QTextStream>
#include <QUuid>

namespace IG {

SessionManager::SessionManager(QObject * parent) : QObject(parent), m_isLoggedIn(false) {
    initializePaths();
    initializeUuid();
    loadSession();
}

SessionManager::~SessionManager() {}

void SessionManager::initializePaths() {
    m_dataPath = QDir(QStandardPaths::writableLocation(QStandardPaths::CacheLocation));
    m_photosPath = QDir(QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation));

    if (!m_dataPath.exists()) {
        m_dataPath.mkpath(m_dataPath.absolutePath());
    }

    if (!m_photosPath.exists()) {
        m_photosPath.mkpath(m_photosPath.absolutePath());
    }
}

void SessionManager::initializeUuid() {
    // Load persisted UUIDs, or generate new ones if not found
    QString uuidPath = m_dataPath.absolutePath() + "/uuid.dat";
    QString phoneIdPath = m_dataPath.absolutePath() + "/phoneId.dat";
    QString adIdPath = m_dataPath.absolutePath() + "/advertisingId.dat";

    // UUID
    QFile uuidFile(uuidPath);
    if (uuidFile.exists() && uuidFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_uuid = QTextStream(&uuidFile).readAll().trimmed();
        uuidFile.close();
    }
    if (m_uuid.isEmpty()) {
        QString uuid = QUuid::createUuid().toString();
        m_uuid = uuid.mid(1, uuid.length() - 2);
    }

    // Phone ID
    QFile phoneIdFile(phoneIdPath);
    if (phoneIdFile.exists() && phoneIdFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_phoneId = QTextStream(&phoneIdFile).readAll().trimmed();
        phoneIdFile.close();
    }
    if (m_phoneId.isEmpty()) {
        QString phoneId = QUuid::createUuid().toString();
        m_phoneId = phoneId.mid(1, phoneId.length() - 2);
    }

    // Advertising ID
    QFile adIdFile(adIdPath);
    if (adIdFile.exists() && adIdFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_advertisingId = QTextStream(&adIdFile).readAll().trimmed();
        adIdFile.close();
    }
    if (m_advertisingId.isEmpty()) {
        QString adId = QUuid::createUuid().toString();
        m_advertisingId = adId.mid(1, adId.length() - 2);
    }

    // Persist all three
    if (uuidFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream(&uuidFile) << m_uuid;
        uuidFile.close();
    }
    if (phoneIdFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream(&phoneIdFile) << m_phoneId;
        phoneIdFile.close();
    }
    if (adIdFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream(&adIdFile) << m_advertisingId;
        adIdFile.close();
    }
}

void SessionManager::regenerateUuid() {
    // Force new UUIDs by clearing the members first
    m_uuid.clear();
    m_phoneId.clear();
    m_advertisingId.clear();
    initializeUuid();
    emit sessionChanged();
}

void SessionManager::setUsername(const QString & username) {
    if (m_username != username) {
        m_username = username;
        m_deviceId = generateDeviceId();
        emit sessionChanged();
    }
}

void SessionManager::setPassword(const QString & password) {
    if (m_password != password) {
        m_password = password;
        m_deviceId = generateDeviceId();
        emit sessionChanged();
    }
}

void SessionManager::setUserId(const QString & userId) {
    if (m_userId != userId) {
        m_userId = userId;
        updateRankToken();
        emit sessionChanged();
    }
}

void SessionManager::setCsrfToken(const QString & token) {
    if (m_csrfToken != token) {
        m_csrfToken = token;
        emit sessionChanged();
    }
}

void SessionManager::setProfilePic(const QString & pic) {
    if (m_profilePic != pic) {
        m_profilePic = pic;
        emit sessionChanged();
    }
}

void SessionManager::setLoggedIn(bool loggedIn) {
    if (m_isLoggedIn != loggedIn) {
        m_isLoggedIn = loggedIn;
        emit loginStateChanged(loggedIn);
        emit sessionChanged();
    }
}

void SessionManager::setAuthorizationHeader(const QString & header) {
    if (m_authorizationHeader != header) {
        m_authorizationHeader = header;
        emit sessionChanged();
    }
}

QVariantMap SessionManager::authenticatedParams() const {
    QVariantMap params;
    params["_uuid"] = m_uuid;
    params["_uid"] = m_userId;
    params["_csrftoken"] = m_csrfToken;
    return params;
}

void SessionManager::saveSession() {
    // Save user ID
    QFile userIdFile(m_dataPath.absolutePath() + "/userId.dat");
    if (userIdFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&userIdFile);
        out << m_userId;
        userIdFile.close();
    }

    // Save CSRF token
    QFile tokenFile(m_dataPath.absolutePath() + "/token.dat");
    if (tokenFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&tokenFile);
        out << m_csrfToken;
        tokenFile.close();
    }

    // Save authorization header (modern Instagram auth)
    QFile authFile(m_dataPath.absolutePath() + "/authorization.dat");
    if (authFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&authFile);
        out << m_authorizationHeader;
        authFile.close();
    }
}

void SessionManager::loadSession() {
    QFile userIdFile(m_dataPath.absolutePath() + "/userId.dat");
    QFile tokenFile(m_dataPath.absolutePath() + "/token.dat");
    QFile authFile(m_dataPath.absolutePath() + "/authorization.dat");

    // Load authorization header (modern Instagram auth)
    if (authFile.exists() && authFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&authFile);
        m_authorizationHeader = in.readAll().trimmed();
        authFile.close();
    }

    if (userIdFile.exists()) {
        // Load user ID
        if (userIdFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&userIdFile);
            m_userId = in.readAll().trimmed();
            userIdFile.close();
        }

        // Load CSRF token
        if (tokenFile.exists() && tokenFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&tokenFile);
            m_csrfToken = in.readAll().trimmed();
            tokenFile.close();
        }

        // Session is valid if we have userId AND either authorization header or
        // CSRF token
        if (!m_userId.isEmpty() && (!m_authorizationHeader.isEmpty() || !m_csrfToken.isEmpty())) {
            m_isLoggedIn = true;
            updateRankToken();
        }
    }
}

void SessionManager::clearSession() {
    QFile(m_dataPath.absolutePath() + "/cookies.dat").remove();
    QFile(m_dataPath.absolutePath() + "/userId.dat").remove();
    QFile(m_dataPath.absolutePath() + "/token.dat").remove();
    QFile(m_dataPath.absolutePath() + "/authorization.dat").remove();
    QFile(m_dataPath.absolutePath() + "/uuid.dat").remove();
    QFile(m_dataPath.absolutePath() + "/phoneId.dat").remove();
    QFile(m_dataPath.absolutePath() + "/advertisingId.dat").remove();

    m_isLoggedIn = false;
    m_userId.clear();
    m_csrfToken.clear();
    m_rankToken.clear();
    m_authorizationHeader.clear();
    m_uuid.clear();
    m_phoneId.clear();
    m_advertisingId.clear();

    // Regenerate UUIDs so subsequent login() calls have valid identifiers
    initializeUuid();

    emit sessionChanged();
    emit loginStateChanged(false);
}

QString SessionManager::generateDeviceId() {
    QFileInfo fi(m_dataPath.absolutePath());
    QByteArray volatileSeed = QString::number(fi.birthTime().toMSecsSinceEpoch()).toUtf8();

    QByteArray data1 =
        QCryptographicHash::hash(QString(m_username + m_password).toUtf8(), QCryptographicHash::Md5)
            .toHex();

    QString data2 = QString(
        QCryptographicHash::hash(QString(data1 + volatileSeed).toUtf8(), QCryptographicHash::Md5)
            .toHex());

    return "android-" + data2.left(16);
}

void SessionManager::updateRankToken() {
    m_rankToken = m_userId + "_" + m_uuid;
}

QString SessionManager::generateCsrfToken() {
    // Generate a random 64-character alphanumeric token (following instagrapi
    // approach)
    const QString chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    QString token;
    token.reserve(64);

    for (int i = 0; i < 64; ++i) {
        int index = QRandomGenerator::global()->bounded(chars.length());
        token.append(chars.at(index));
    }

    return token;
}

void SessionManager::ensureCsrfToken() {
    if (m_csrfToken.isEmpty()) {
        m_csrfToken = generateCsrfToken();
        emit sessionChanged();
    }
}

} // namespace IG
