#include "Response.h"
#include <QJsonDocument>

namespace IG {

Response::Response(const QByteArray & data, int httpCode) : m_rawData(data), m_httpCode(httpCode) {
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error == QJsonParseError::NoError) {
        m_json = doc.object();
    } else {
        m_errorMessage = "JSON parse error: " + parseError.errorString();
    }
}

Response::Response(const QJsonObject & json, int httpCode) : m_json(json), m_httpCode(httpCode) {
    m_rawData = QJsonDocument(json).toJson(QJsonDocument::Compact);
}

Response Response::error(const QString & message, int code) {
    Response response(QByteArray(), code);
    response.m_errorMessage = message;
    return response;
}

bool Response::ok() const {
    if (!m_errorMessage.isEmpty()) {
        return false;
    }
    return m_json["status"].toString() == "ok";
}

QVariant Response::toVariant() const {
    return QVariant(m_rawData);
}

QString Response::errorMessage() const {
    if (!m_errorMessage.isEmpty()) {
        return m_errorMessage;
    }

    // Try to get error from JSON response
    if (m_json.contains("message")) {
        return m_json["message"].toString();
    }
    if (m_json.contains("error_message")) {
        return m_json["error_message"].toString();
    }

    if (!ok()) {
        return "Unknown error";
    }

    return QString();
}

bool Response::isLoginRequired() const {
    QString msg = m_json["message"].toString();
    QString errorType = m_json["error_type"].toString();
    return msg == "login_required" || errorType == "login_required";
}

bool Response::isTwoFactorRequired() const {
    return m_json["two_factor_required"].toBool();
}

bool Response::isChallengeRequired() const {
    QString msg = m_json["message"].toString();
    return msg == "challenge_required";
}

bool Response::isCheckpointRequired() const {
    QString msg = m_json["message"].toString();
    QString errorType = m_json["error_type"].toString();
    return msg == "checkpoint_required" || errorType == "checkpoint_challenge_required" ||
           errorType == "checkpoint_logged_out";
}

bool Response::isThrottled() const {
    return m_httpCode == 429;
}

} // namespace IG
