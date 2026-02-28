#include "CookieManager.h"
#include "../utils/Constants.h"
#include <QFile>
#include <QDataStream>
#include <QUrl>
#include <QRegExp>
#include <QTextStream>

namespace IG {

CookieManager::CookieManager(const QString& dataPath, QObject* parent)
    : QObject(parent)
    , m_dataPath(dataPath)
    , m_cookieJar(new QNetworkCookieJar(this))
{
    loadCookies();
}

CookieManager::~CookieManager() {
}

void CookieManager::loadCookies() {
    QFile f(m_dataPath + "/cookies.dat");
    if (!f.open(QIODevice::ReadOnly)) {
        return;
    }

    QDataStream s(&f);
    while (!s.atEnd()) {
        QByteArray c;
        s >> c;
        QList<QNetworkCookie> list = QNetworkCookie::parseCookies(c);
        if (list.count() > 0) {
            m_cookieJar->insertCookie(list.at(0));
        }
    }
    f.close();
}

void CookieManager::saveCookies() {
    // Try multiple URL variants to get all cookies
    QList<QNetworkCookie> list = m_cookieJar->cookiesForUrl(QUrl(Constants::apiUrl() + "/"));
    
    // Also get cookies from i.instagram.com
    QList<QNetworkCookie> iCookies = m_cookieJar->cookiesForUrl(QUrl("https://i.instagram.com/"));
    
    // Merge cookies
    for (const QNetworkCookie& cookie : iCookies) {
        bool found = false;
        for (const QNetworkCookie& existing : list) {
            if (existing.name() == cookie.name()) {
                found = true;
                break;
            }
        }
        if (!found) {
            list.append(cookie);
        }
    }

    QFile f(m_dataPath + "/cookies.dat");
    if (!f.open(QIODevice::WriteOnly)) {
        return;
    }

    QDataStream s(&f);
    for (int i = 0; i < list.size(); ++i) {
        s << list.at(i).toRawForm();
    }
    f.close();

    emit cookiesSaved();
}

void CookieManager::clearCookies() {
    QFile(m_dataPath + "/cookies.dat").remove();
    
    // Delete the old cookie jar immediately to prevent memory leak
    // if clearCookies() is called multiple times before deleteLater() executes
    delete m_cookieJar;
    m_cookieJar = new QNetworkCookieJar(this);
}

QString CookieManager::extractCsrfToken() const {
    // First try to get from cookie jar directly
    QList<QNetworkCookie> cookies = m_cookieJar->cookiesForUrl(QUrl("https://i.instagram.com/"));
    
    for (const QNetworkCookie& cookie : cookies) {
        if (cookie.name() == "csrftoken") {
            return QString::fromUtf8(cookie.value());
        }
    }
    
    // Also try with different URL variants
    QList<QNetworkCookie> allCookies = m_cookieJar->cookiesForUrl(QUrl("https://www.instagram.com/"));
    for (const QNetworkCookie& cookie : allCookies) {
        if (cookie.name() == "csrftoken") {
            return QString::fromUtf8(cookie.value());
        }
    }
    
    // Fallback: try from file
    QFile f(m_dataPath + "/cookies.dat");
    if (!f.open(QIODevice::ReadOnly)) {
        return QString();
    }

    QTextStream in(&f);
    QString content = in.readAll();
    f.close();

    QRegExp rx("csrftoken=(\\w+)");
    if (rx.indexIn(content) != -1) {
        return rx.cap(1);
    }
    return QString();
}

QString CookieManager::extractSessionId() const {
    QList<QNetworkCookie> cookies = m_cookieJar->cookiesForUrl(QUrl("https://i.instagram.com/"));
    for (const QNetworkCookie& cookie : cookies) {
        if (cookie.name() == "sessionid") {
            return QString::fromUtf8(cookie.value());
        }
    }

    QList<QNetworkCookie> allCookies = m_cookieJar->cookiesForUrl(QUrl("https://www.instagram.com/"));
    for (const QNetworkCookie& cookie : allCookies) {
        if (cookie.name() == "sessionid") {
            return QString::fromUtf8(cookie.value());
        }
    }

    return QString();
}

bool CookieManager::hasCookies() const {
    return QFile::exists(m_dataPath + "/cookies.dat");
}

} // namespace IG
