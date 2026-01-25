#include "ErrorHandler.h"
#include <QJsonDocument>
#include <QJsonObject>

namespace IG {

ClientError ErrorHandler::parseResponse(const QString& response, int httpCode) {
    if (response.isEmpty()) {
        return ClientError(ClientError::Type::InvalidResponse, "Empty response", httpCode);
    }

    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
    if (doc.isNull() || !doc.isObject()) {
        return ClientError(ClientError::Type::InvalidResponse, "Invalid JSON response", response, httpCode);
    }

    QJsonObject obj = doc.object();
    QString status = obj.value("status").toString();
    
    if (status == "ok") {
        return ClientError(); // No error
    }

    QString message = obj.value("message").toString();
    if (message.isEmpty()) {
        message = obj.value("error_title").toString();
    }

    ClientError::Type errorType = ClientError::Type::Unknown;

    // Check for specific error types
    if (obj.contains("two_factor_required") && obj.value("two_factor_required").toBool()) {
        errorType = ClientError::Type::TwoFactorRequired;
        ClientError error(errorType, message, response, httpCode);
        if (obj.contains("two_factor_info")) {
            error.setTwoFactorInfo(obj.value("two_factor_info").toObject().toVariantMap());
        }
        return error;
    }

    if (message == "challenge_required") {
        errorType = ClientError::Type::ChallengeRequired;
        ClientError error(errorType, message, response, httpCode);
        if (obj.contains("challenge")) {
            error.setChallengeInfo(obj.value("challenge").toObject().toVariantMap());
        }
        return error;
    }

    if (message == "checkpoint_required") {
        errorType = ClientError::Type::CheckpointRequired;
    } else if (message == "login_required") {
        errorType = ClientError::Type::LoginRequired;
    } else if (message.contains("Please wait") || message.contains("try again")) {
        errorType = ClientError::Type::RateLimit;
    } else if (httpCode == 400) {
        errorType = ClientError::Type::BadRequest;
    } else if (httpCode == 401 || httpCode == 403) {
        errorType = ClientError::Type::Auth;
    } else if (httpCode == 404) {
        errorType = ClientError::Type::NotFound;
    } else if (status == "fail") {
        errorType = ClientError::Type::Auth;
    }

    return ClientError(errorType, message, response, httpCode);
}

ClientError ErrorHandler::fromNetworkError(QNetworkReply::NetworkError error, const QString& errorString) {
    ClientError::Type type = ClientError::Type::Network;
    
    if (error == QNetworkReply::TimeoutError || 
        error == QNetworkReply::OperationCanceledError) {
        type = ClientError::Type::Timeout;
    }
    
    return ClientError(type, errorString, 0);
}

bool ErrorHandler::isSuccess(const QJsonObject& response) {
    QString status = response.value("status").toString();
    return status == "ok" || status.isEmpty();
}

bool ErrorHandler::isSuccess(const QString& response) {
    QJsonDocument doc = QJsonDocument::fromJson(response.toUtf8());
    if (doc.isNull() || !doc.isObject()) {
        return false;
    }
    return isSuccess(doc.object());
}

} // namespace IG
