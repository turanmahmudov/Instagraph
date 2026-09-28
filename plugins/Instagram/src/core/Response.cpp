#include "Response.h"
#include <QJsonDocument>

namespace IG {

namespace {

// Largest integer a JavaScript number holds exactly: 2^53 - 1
const QByteArray maxSafeInteger = QByteArrayLiteral("9007199254740991");

bool isUnsafeInteger(const QByteArray & digits) {
    if (digits.size() != maxSafeInteger.size()) {
        return digits.size() > maxSafeInteger.size();
    }
    return digits > maxSafeInteger;
}

int skipDigits(const QByteArray & json, int pos) {
    while (pos < json.size() && json.at(pos) >= '0' && json.at(pos) <= '9') {
        ++pos;
    }
    return pos;
}

QByteArray quoteUnsafeIntegers(const QByteArray & json) {
    QByteArray result;
    result.reserve(json.size() + 64);

    bool inString = false;
    bool escaped = false;
    int i = 0;
    while (i < json.size()) {
        const char c = json.at(i);

        if (inString) {
            result.append(c);
            if (escaped) {
                escaped = false;
            } else if (c == '\\') {
                escaped = true;
            } else if (c == '"') {
                inString = false;
            }
            ++i;
            continue;
        }

        if (c == '"') {
            inString = true;
            result.append(c);
            ++i;
            continue;
        }

        if (c == '-' || (c >= '0' && c <= '9')) {
            int end = i + (c == '-' ? 1 : 0);
            const int digitsStart = end;
            end = skipDigits(json, end);
            const int digitsEnd = end;

            bool isInteger = true;
            if (end < json.size() && json.at(end) == '.') {
                isInteger = false;
                end = skipDigits(json, end + 1);
            }
            if (end < json.size() && (json.at(end) == 'e' || json.at(end) == 'E')) {
                isInteger = false;
                ++end;
                if (end < json.size() && (json.at(end) == '+' || json.at(end) == '-')) {
                    ++end;
                }
                end = skipDigits(json, end);
            }

            const QByteArray token = json.mid(i, end - i);
            const QByteArray digits = json.mid(digitsStart, digitsEnd - digitsStart);
            if (isInteger && isUnsafeInteger(digits)) {
                result.append('"').append(token).append('"');
            } else {
                result.append(token);
            }
            i = end;
            continue;
        }

        result.append(c);
        ++i;
    }

    return result;
}

} // namespace

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
    return QVariant(QString::fromUtf8(quoteUnsafeIntegers(m_rawData)));
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
