#ifndef INSTAGRAM_APICLIENT_H
#define INSTAGRAM_APICLIENT_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <functional>
#include <memory>

#include "Request.h"
#include "Response.h"

namespace IG {

class SessionManager;
class CookieManager;

/**
 * @brief Callback type for handling responses
 */
using ResponseCallback = std::function<void(const Response&)>;

/**
 * @brief Central API client that executes requests
 * 
 * This is the core class that handles all HTTP communication.
 * It manages request correlation, authentication injection,
 * and response parsing.
 * 
 * Usage:
 *   client->execute(request, [this](const Response& response) {
 *       if (response.ok()) {
 *           emit dataReady(response.toVariant());
 *       } else {
 *           emit error(response.errorMessage());
 *       }
 *   });
 */
class ApiClient : public QObject {
    Q_OBJECT

public:
    explicit ApiClient(SessionManager* session, CookieManager* cookies, 
                       QObject* parent = nullptr);
    ~ApiClient();

    /**
     * @brief Execute a request with a callback for the response
     * @param request The request to execute
     * @param callback Function to call with the response
     * @return Request ID for tracking/cancellation
     */
    QString execute(const Request& request, ResponseCallback callback);

    /**
     * @brief Execute a request and emit a signal with the response
     * @param request The request to execute
     * @param receiver Object to emit signal on
     * @param signal Signal to emit (must take QVariant)
     * @return Request ID for tracking/cancellation
     */
    template<typename T>
    QString execute(const Request& request, T* receiver, void (T::*signal)(QVariant)) {
        return execute(request, [receiver, signal](const Response& response) {
            emit (receiver->*signal)(response.toVariant());
        });
    }

    /**
     * @brief Cancel a pending request
     */
    void cancel(const QString& requestId);

    /**
     * @brief Cancel all pending requests
     */
    void cancelAll();

    /**
     * @brief Set custom network manager (for testing/proxy)
     */
    void setNetworkManager(QNetworkAccessManager* manager);

    /**
     * @brief Get the network manager
     */
    QNetworkAccessManager* networkManager() const { return m_network; }

signals:
    /**
     * @brief Emitted for any error (network, auth, etc.)
     */
    void error(const QString& message);

    /**
     * @brief Emitted when upload progress changes
     */
    void uploadProgress(const QString& requestId, double percent);

private slots:
    void onReplyFinished(QNetworkReply* reply);

private:
    QUrl buildUrl(const Request& request) const;
    QByteArray buildBody(const Request& request) const;
    QNetworkRequest buildNetworkRequest(const Request& request) const;
    void injectAuthParams(Request& request) const;
    QString generateSignature(const QJsonObject& data) const;
    void parseAuthorizationHeader(const QString& header);

    SessionManager* m_session;
    CookieManager* m_cookies;
    QNetworkAccessManager* m_network;
    bool m_ownsNetwork;

    // Map request ID -> callback
    QMap<QString, ResponseCallback> m_pendingCallbacks;
    // Map QNetworkReply* -> request ID
    QMap<QNetworkReply*, QString> m_replyToRequestId;
};

} // namespace IG

#endif // INSTAGRAM_APICLIENT_H
