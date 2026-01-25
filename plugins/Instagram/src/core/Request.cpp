#include "Request.h"
#include <QUuid>

namespace IG {

// ============================================================================
// RequestBuilder
// ============================================================================

RequestBuilder::RequestBuilder(HttpMethod method, const QString& endpoint)
    : m_method(method)
    , m_endpoint(endpoint)
{
}

RequestBuilder RequestBuilder::get(const QString& endpoint) {
    return RequestBuilder(HttpMethod::GET, endpoint);
}

RequestBuilder RequestBuilder::post(const QString& endpoint) {
    return RequestBuilder(HttpMethod::POST, endpoint);
}

RequestBuilder& RequestBuilder::pathParam(const QString& name, const QString& value) {
    m_endpoint.replace("{" + name + "}", value);
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, const QString& value) {
    m_params.insert(key, QJsonValue(value));
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, const char* value) {
    // Handle C string literals explicitly to avoid bool conversion
    m_params.insert(key, QJsonValue(QString(value)));
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, int value) {
    m_params.insert(key, value);
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, bool value) {
    m_params.insert(key, value);
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, const QJsonObject& value) {
    m_params.insert(key, value);
    return *this;
}

RequestBuilder& RequestBuilder::param(const QString& key, const QJsonArray& value) {
    m_params.insert(key, value);
    return *this;
}

RequestBuilder& RequestBuilder::queryParam(const QString& key, const QString& value) {
    m_query.addQueryItem(key, value);
    return *this;
}

RequestBuilder& RequestBuilder::authenticated() {
    m_authenticated = true;
    return *this;
}

RequestBuilder& RequestBuilder::unsigned_() {
    m_signed = false;
    return *this;
}

RequestBuilder& RequestBuilder::apiV2() {
    m_apiV2 = true;
    return *this;
}

RequestBuilder& RequestBuilder::multipart(const QString& boundary) {
    m_contentType = ContentType::Multipart;
    m_boundary = boundary;
    m_signed = false;  // Multipart requests are not signed
    return *this;
}

RequestBuilder& RequestBuilder::rawBody(const QByteArray& body) {
    m_rawBody = body;
    return *this;
}

Request RequestBuilder::build() const {
    Request request;
    request.m_method = m_method;
    request.m_endpoint = m_endpoint;
    request.m_params = m_params;
    request.m_query = m_query;
    request.m_authenticated = m_authenticated;
    request.m_signed = m_signed;
    request.m_apiV2 = m_apiV2;
    request.m_contentType = m_contentType;
    request.m_boundary = m_boundary;
    request.m_rawBody = m_rawBody;
    
    // Generate unique request ID for tracking
    QString uuid = QUuid::createUuid().toString();
    request.m_requestId = uuid.mid(1, uuid.length() - 2);
    
    return request;
}

} // namespace IG
