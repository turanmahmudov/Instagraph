#ifndef INSTAGRAM_REQUEST_H
#define INSTAGRAM_REQUEST_H

#include <QString>
#include <QJsonObject>
#include <QJsonArray>
#include <QUrlQuery>
#include <QMap>
#include <QByteArray>

namespace IG {

/**
 * @brief HTTP method enum
 */
enum class HttpMethod {
    GET,
    POST
};

/**
 * @brief Content type for request body
 */
enum class ContentType {
    FormUrlEncoded,  // application/x-www-form-urlencoded
    Multipart        // multipart/form-data
};

/**
 * @brief Immutable request object built via RequestBuilder
 * 
 * Represents a single API request with all its parameters,
 * headers, and configuration.
 */
class Request {
public:
    HttpMethod method() const { return m_method; }
    QString endpoint() const { return m_endpoint; }
    QJsonObject params() const { return m_params; }
    QUrlQuery query() const { return m_query; }
    bool isAuthenticated() const { return m_authenticated; }
    bool isSigned() const { return m_signed; }
    bool isApiV2() const { return m_apiV2; }
    QString requestId() const { return m_requestId; }
    ContentType contentType() const { return m_contentType; }
    QString boundary() const { return m_boundary; }
    QByteArray rawBody() const { return m_rawBody; }
    bool hasRawBody() const { return !m_rawBody.isEmpty(); }

private:
    friend class RequestBuilder;
    
    HttpMethod m_method = HttpMethod::GET;
    QString m_endpoint;
    QJsonObject m_params;
    QUrlQuery m_query;
    bool m_authenticated = false;
    bool m_signed = true;
    bool m_apiV2 = false;
    QString m_requestId;
    ContentType m_contentType = ContentType::FormUrlEncoded;
    QString m_boundary;
    QByteArray m_rawBody;
};

/**
 * @brief Fluent builder for constructing Request objects
 * 
 * Usage:
 *   auto request = RequestBuilder::post("media/{media_id}/like/")
 *       .pathParam("media_id", "12345")
 *       .param("module_name", "feed_timeline")
 *       .authenticated()
 *       .build();
 */
class RequestBuilder {
public:
    /**
     * @brief Create a GET request builder
     */
    static RequestBuilder get(const QString& endpoint);
    
    /**
     * @brief Create a POST request builder
     */
    static RequestBuilder post(const QString& endpoint);

    /**
     * @brief Replace a path parameter like {media_id} with actual value
     */
    RequestBuilder& pathParam(const QString& name, const QString& value);

    /**
     * @brief Add a body parameter (for POST)
     */
    RequestBuilder& param(const QString& key, const QString& value);
    RequestBuilder& param(const QString& key, const char* value);  // Handle C string literals
    RequestBuilder& param(const QString& key, int value);
    RequestBuilder& param(const QString& key, bool value);
    RequestBuilder& param(const QString& key, const QJsonObject& value);
    RequestBuilder& param(const QString& key, const QJsonArray& value);

    /**
     * @brief Add a query parameter (for URL ?key=value)
     */
    RequestBuilder& queryParam(const QString& key, const QString& value);

    /**
     * @brief Add standard auth params (_uuid, _uid, _csrftoken)
     */
    RequestBuilder& authenticated();

    /**
     * @brief Use unsigned request (no signature)
     */
    RequestBuilder& unsigned_();

    /**
     * @brief Use API v2 URL
     */
    RequestBuilder& apiV2();

    /**
     * @brief Set multipart content type with boundary
     */
    RequestBuilder& multipart(const QString& boundary);

    /**
     * @brief Set raw body data (for multipart)
     */
    RequestBuilder& rawBody(const QByteArray& body);

    /**
     * @brief Build the immutable Request object
     */
    Request build() const;

private:
    explicit RequestBuilder(HttpMethod method, const QString& endpoint);

    HttpMethod m_method;
    QString m_endpoint;
    QJsonObject m_params;
    QUrlQuery m_query;
    bool m_authenticated = false;
    bool m_signed = true;
    bool m_apiV2 = false;
    ContentType m_contentType = ContentType::FormUrlEncoded;
    QString m_boundary;
    QByteArray m_rawBody;
};

} // namespace IG

#endif // INSTAGRAM_REQUEST_H
