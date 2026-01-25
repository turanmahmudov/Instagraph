#include "ClientError.h"

namespace IG {

ClientError::ClientError()
    : m_type(Type::None)
    , m_httpCode(0)
{
}

ClientError::ClientError(Type type, const QString& message, int httpCode)
    : m_type(type)
    , m_httpCode(httpCode)
    , m_message(message)
{
}

ClientError::ClientError(Type type, const QString& message, const QString& rawResponse, int httpCode)
    : m_type(type)
    , m_httpCode(httpCode)
    , m_message(message)
    , m_rawResponse(rawResponse)
{
}

void ClientError::setTwoFactorInfo(const QVariantMap& info) {
    m_details["two_factor_info"] = info;
}

void ClientError::setChallengeInfo(const QVariantMap& info) {
    m_details["challenge"] = info;
}

QString ClientError::typeToString(Type type) {
    switch (type) {
        case Type::None: return "None";
        case Type::Unknown: return "Unknown";
        case Type::Network: return "Network";
        case Type::Timeout: return "Timeout";
        case Type::Auth: return "Auth";
        case Type::LoginRequired: return "LoginRequired";
        case Type::TwoFactorRequired: return "TwoFactorRequired";
        case Type::ChallengeRequired: return "ChallengeRequired";
        case Type::CheckpointRequired: return "CheckpointRequired";
        case Type::RateLimit: return "RateLimit";
        case Type::InvalidResponse: return "InvalidResponse";
        case Type::BadRequest: return "BadRequest";
        case Type::NotFound: return "NotFound";
        case Type::Forbidden: return "Forbidden";
        default: return "Unknown";
    }
}

} // namespace IG
