#ifndef INSTAGRAM_COOKIEMANAGER_H
#define INSTAGRAM_COOKIEMANAGER_H

#include <QObject>
#include <QNetworkCookieJar>
#include <QNetworkCookie>
#include <QList>
#include <QString>

namespace IG {

class CookieManager : public QObject {
    Q_OBJECT
public:
    explicit CookieManager(const QString& dataPath, QObject* parent = nullptr);
    ~CookieManager();

    QNetworkCookieJar* cookieJar() const { return m_cookieJar; }

    void loadCookies();
    void saveCookies();
    void clearCookies();

    QString extractCsrfToken() const;
    QString extractSessionId() const;
    bool hasCookies() const;

signals:
    void cookiesSaved();
    void cookieJarChanged();

private:
    QString m_dataPath;
    QNetworkCookieJar* m_cookieJar;
};

} // namespace IG

#endif // INSTAGRAM_COOKIEMANAGER_H
