#include "ApiClient.h"
#include "../network/CookieManager.h"
#include "../network/SignatureGenerator.h"
#include "../session/SessionManager.h"
#include "../utils/Constants.h"
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkCookie>
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QtDebug>

namespace IG {

ApiClient::ApiClient(SessionManager * session, CookieManager * cookies, QObject * parent)
    : QObject(parent), m_session(session), m_cookies(cookies),
      m_network(new QNetworkAccessManager(this)), m_ownsNetwork(true) {
    connect(m_network, &QNetworkAccessManager::finished, this, &ApiClient::onReplyFinished);

    // Set cookie jar - following the pattern from v2 code
    // Key: set the cookie jar, then restore parent to prevent
    // QNetworkAccessManager from deleting it
    if (m_cookies && m_cookies->cookieJar()) {
        m_network->setCookieJar(m_cookies->cookieJar());
        m_cookies->cookieJar()->setParent(m_cookies); // Keep CookieManager as owner
    }

    // When the cookie jar is replaced (e.g. after logout), reassign to the
    // network manager
    if (m_cookies) {
        connect(m_cookies, &CookieManager::cookieJarChanged, this, [this]() {
            if (m_cookies->cookieJar()) {
                m_network->setCookieJar(m_cookies->cookieJar());
                m_cookies->cookieJar()->setParent(m_cookies);
            }
        });
    }
}

ApiClient::~ApiClient() {
    disconnect(m_network, &QNetworkAccessManager::finished, this, &ApiClient::onReplyFinished);
    cancelAll();
}

QString ApiClient::execute(const Request & request, ResponseCallback callback) {
    // Store callback for this request
    QString requestId = request.requestId();
    m_pendingCallbacks[requestId] = callback;

    // Build the network request
    QNetworkRequest netRequest = buildNetworkRequest(request);

    // DEBUG: Log request details
    qDebug() << "========== API REQUEST ==========";
    qDebug() << "URL:" << netRequest.url().toString();
    qDebug() << "Method:" << (request.method() == HttpMethod::GET ? "GET" : "POST");
    qDebug() << "Headers:";
    for (const QByteArray & header : netRequest.rawHeaderList()) {
        qDebug() << "  " << header << ":" << netRequest.rawHeader(header);
    }

    QNetworkReply * reply = nullptr;

    if (request.method() == HttpMethod::GET) {
        reply = m_network->get(netRequest);
    } else {
        QByteArray body = buildBody(request);
        if (request.contentType() == ContentType::OctetStream) {
            qDebug() << "Body:" << body.size() << "bytes";
        } else {
            qDebug() << "Body:" << body;
        }
        reply = m_network->post(netRequest, body);
    }
    qDebug() << "=================================";

    // Track reply -> request ID mapping
    m_replyToRequestId[reply] = requestId;

    // Connect upload progress if needed
    connect(reply, &QNetworkReply::uploadProgress, this,
            [this, requestId](qint64 sent, qint64 total) {
                if (total > 0) {
                    double percent = (static_cast<double>(sent) / total) * 100.0;
                    emit uploadProgress(requestId, percent);
                }
            });

    return requestId;
}

void ApiClient::cancel(const QString & requestId) {
    m_pendingCallbacks.remove(requestId);

    // Find and abort the reply
    for (auto it = m_replyToRequestId.begin(); it != m_replyToRequestId.end(); ++it) {
        if (it.value() == requestId) {
            it.key()->abort();
            break;
        }
    }
}

void ApiClient::cancelAll() {
    m_pendingCallbacks.clear();

    const QList<QNetworkReply *> replies = m_replyToRequestId.keys();
    m_replyToRequestId.clear();
    for (QNetworkReply * reply : replies) {
        reply->abort();
    }
}

void ApiClient::setNetworkManager(QNetworkAccessManager * manager) {
    if (m_ownsNetwork && m_network) {
        m_network->deleteLater();
    }
    m_network = manager;
    m_ownsNetwork = false;

    connect(m_network, &QNetworkAccessManager::finished, this, &ApiClient::onReplyFinished);

    // Set cookie jar on the new network manager - keep CookieManager as owner
    if (m_cookies && m_cookies->cookieJar()) {
        m_network->setCookieJar(m_cookies->cookieJar());
        m_cookies->cookieJar()->setParent(m_cookies);
    }
}

void ApiClient::onReplyFinished(QNetworkReply * reply) {
    // Process response headers for auth and cookies
    QList<QByteArray> allHeaders = reply->rawHeaderList();
    for (const QByteArray & headerName : allHeaders) {
        QByteArray headerValue = reply->rawHeader(headerName);

        // Check for Instagram's authorization header
        if (headerName.toLower() == "ig-set-authorization") {
            QString authHeader = QString::fromUtf8(headerValue);
            m_session->setAuthorizationHeader(authHeader);
            parseAuthorizationHeader(authHeader);
        }

        // Extract cookies from Set-Cookie headers
        if (headerName.toLower() == "set-cookie") {
            QList<QNetworkCookie> cookies = QNetworkCookie::parseCookies(headerValue);
            for (const QNetworkCookie & cookie : cookies) {
                if (m_cookies && m_cookies->cookieJar()) {
                    m_cookies->cookieJar()->insertCookie(cookie);
                }
                // If this is the csrftoken, save it directly to session
                if (cookie.name() == "csrftoken") {
                    m_session->setCsrfToken(QString::fromUtf8(cookie.value()));
                }
            }
        }
    }

    // Also check for multiple Set-Cookie headers using the variant method
    QVariant cookieVariant = reply->header(QNetworkRequest::SetCookieHeader);
    if (cookieVariant.isValid()) {
        QList<QNetworkCookie> cookies = cookieVariant.value<QList<QNetworkCookie>>();
        for (const QNetworkCookie & cookie : cookies) {
            if (m_cookies && m_cookies->cookieJar()) {
                m_cookies->cookieJar()->insertCookie(cookie);
            }
            if (cookie.name() == "csrftoken") {
                m_session->setCsrfToken(QString::fromUtf8(cookie.value()));
            }
        }
    }

    reply->deleteLater();

    // Get request ID for this reply
    QString requestId = m_replyToRequestId.take(reply);
    if (requestId.isEmpty()) {
        return; // Request was cancelled
    }

    // Get callback
    ResponseCallback callback = m_pendingCallbacks.take(requestId);
    if (!callback) {
        return; // No callback registered
    }

    // Always read the response body first - Instagram sends useful error info
    // even on errors
    QByteArray data = reply->readAll();
    int httpCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    // DEBUG: Log response details
    qDebug() << "========== API RESPONSE ==========";
    qDebug() << "URL:" << reply->url().toString();
    qDebug() << "HTTP Status:" << httpCode;
    qDebug() << "Response Headers:";
    for (const QByteArray & header : reply->rawHeaderList()) {
        qDebug() << "  " << header << ":" << reply->rawHeader(header);
    }
    qDebug() << "Response Body:" << data;
    qDebug() << "==================================";

    // Handle network errors - but still include response body in debug
    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "[ApiClient] Network error:" << reply->error() << reply->errorString();
        Response response(data, httpCode);
        callback(response);
        return;
    }

    Response response(data, httpCode);

    // Check for auth errors
    if (response.isLoginRequired()) {
        emit error("Login required");
    }

    callback(response);
}

QUrl ApiClient::buildUrl(const Request & request) const {
    QUrl url(request.url().isEmpty() ? Constants::apiUrl(request.isApiV2()) + request.endpoint()
                                     : request.url());

    if (!request.query().isEmpty()) {
        url.setQuery(request.query());
    }

    return url;
}

QByteArray ApiClient::buildBody(const Request & request) const {
    if (request.method() == HttpMethod::GET) {
        return QByteArray();
    }

    // If raw body is provided (e.g., for multipart), use it directly
    if (request.hasRawBody()) {
        return request.rawBody();
    }

    QJsonObject params = request.params();

    // Inject auth params if requested
    if (request.isAuthenticated()) {
        params.insert("_uuid", m_session->uuid());
        params.insert("_uid", m_session->userId());
        params.insert("_csrftoken", m_session->csrfToken());
    }

    if (request.isSigned()) {
        // Sign the request
        QString signature = SignatureGenerator::generate(params);
        return signature.toUtf8();
    } else {
        // Unsigned request - direct form encoding
        QUrlQuery query;
        for (auto it = params.begin(); it != params.end(); ++it) {
            if (it.value().isString()) {
                query.addQueryItem(it.key(), it.value().toString());
            } else {
                query.addQueryItem(
                    it.key(), QString::fromUtf8(QJsonDocument(QJsonObject{{it.key(), it.value()}})
                                                    .toJson(QJsonDocument::Compact)));
            }
        }
        return query.toString(QUrl::FullyEncoded).toUtf8();
    }
}

QNetworkRequest ApiClient::buildNetworkRequest(const Request & request) const {
    QUrl url = buildUrl(request);
    QNetworkRequest netRequest(url);

    QString locale = Constants::locale();
    QString pigeonSessionId = "UFS-" + m_session->uuid() + "-1";
    QString timestamp = QString::number(QDateTime::currentMSecsSinceEpoch() / 1000.0, 'f', 3);

    // Modern Instagram headers (based on instagrapi 2025)
    netRequest.setRawHeader("X-IG-App-Locale", locale.toUtf8());
    netRequest.setRawHeader("X-IG-Device-Locale", locale.toUtf8());
    netRequest.setRawHeader("X-IG-Mapped-Locale", locale.toUtf8());
    netRequest.setRawHeader("X-Pigeon-Session-Id", pigeonSessionId.toUtf8());
    netRequest.setRawHeader("X-Pigeon-Rawclienttime", timestamp.toUtf8());
    netRequest.setRawHeader("X-IG-Bandwidth-Speed-KBPS", QByteArray::number(qrand() % 500 + 2500));
    netRequest.setRawHeader("X-IG-Bandwidth-TotalBytes-B",
                            QByteArray::number(qrand() % 85000000 + 5000000));
    netRequest.setRawHeader("X-IG-Bandwidth-TotalTime-MS",
                            QByteArray::number(qrand() % 7000 + 2000));
    netRequest.setRawHeader("X-IG-App-Startup-Country", Constants::country().toUpper().toUtf8());
    netRequest.setRawHeader("X-Bloks-Version-Id", Constants::bloksVersionId().toUtf8());
    netRequest.setRawHeader("X-IG-WWW-Claim", "0");
    netRequest.setRawHeader("X-Bloks-Is-Layout-RTL", "false");
    netRequest.setRawHeader("X-Bloks-Is-Panorama-Enabled", "true");
    netRequest.setRawHeader("X-IG-Device-ID", m_session->uuid().toUtf8());
    netRequest.setRawHeader("X-IG-Family-Device-ID", m_session->phoneId().toUtf8());
    netRequest.setRawHeader("X-IG-Android-ID", m_session->deviceId().toUtf8());
    netRequest.setRawHeader("X-IG-Timezone-Offset",
                            QByteArray::number(Constants::timezoneOffset()));
    netRequest.setRawHeader("X-IG-Connection-Type", "WIFI");
    netRequest.setRawHeader("X-IG-Capabilities", Constants::igCapabilities());
    netRequest.setRawHeader("X-IG-App-ID", Constants::appId().toUtf8());
    netRequest.setRawHeader("Priority", "u=3");
    netRequest.setRawHeader("User-Agent", Constants::userAgent());
    netRequest.setRawHeader("Accept-Language", "en-US");
    netRequest.setRawHeader("Host", "i.instagram.com");
    netRequest.setRawHeader("X-FB-HTTP-Engine", "Liger");
    netRequest.setRawHeader("Connection", "keep-alive");
    netRequest.setRawHeader("X-FB-Client-IP", "True");
    netRequest.setRawHeader("X-FB-Server-Cluster", "True");
    netRequest.setRawHeader("IG-INTENDED-USER-ID",
                            m_session->userId().isEmpty() ? "0" : m_session->userId().toUtf8());

    // Add Authorization header if available (modern Instagram auth from
    // ig-set-authorization)
    if (!m_session->authorizationHeader().isEmpty()) {
        netRequest.setRawHeader("Authorization", m_session->authorizationHeader().toUtf8());
    }

    if (request.method() == HttpMethod::POST) {
        if (request.contentType() == ContentType::Multipart) {
            QString contentType =
                QString("multipart/form-data; boundary=%1").arg(request.boundary());
            netRequest.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
        } else if (request.contentType() == ContentType::OctetStream) {
            netRequest.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
        } else {
            netRequest.setHeader(QNetworkRequest::ContentTypeHeader,
                                 "application/x-www-form-urlencoded; charset=UTF-8");
        }
    }

    const QMap<QByteArray, QByteArray> headers = request.headers();
    for (auto it = headers.constBegin(); it != headers.constEnd(); ++it) {
        netRequest.setRawHeader(it.key(), it.value());
    }

    return netRequest;
}

void ApiClient::parseAuthorizationHeader(const QString & header) {
    // Format: "Bearer IGT:2:<base64_json>"
    // We need to extract the base64 part after the last colon
    int lastColon = header.lastIndexOf(':');
    if (lastColon == -1) {
        return;
    }

    QString base64Part = header.mid(lastColon + 1);

    // Decode base64
    QByteArray decoded = QByteArray::fromBase64(base64Part.toUtf8());

    // Parse JSON
    QJsonDocument doc = QJsonDocument::fromJson(decoded);
    if (doc.isNull() || !doc.isObject()) {
        return;
    }

    QJsonObject obj = doc.object();

    // Extract user ID if we don't have one yet
    QString dsUserId = obj["ds_user_id"].toString();
    if (!dsUserId.isEmpty() && m_session->userId().isEmpty()) {
        m_session->setUserId(dsUserId);
    }
}

} // namespace IG
