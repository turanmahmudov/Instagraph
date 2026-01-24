#ifndef INSTAGRAM_RESPONSE_H
#define INSTAGRAM_RESPONSE_H

#include <QString>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QVariant>

namespace IG {

/**
 * @brief Wrapper for API responses with convenient accessors
 * 
 * Provides type-safe access to response data with automatic
 * JSON parsing and error handling.
 */
class Response {
public:
    explicit Response(const QByteArray& data, int httpCode = 200);
    explicit Response(const QJsonObject& json, int httpCode = 200);
    
    /**
     * @brief Create an error response
     */
    static Response error(const QString& message, int code = 0);

    /**
     * @brief Check if request was successful (status == "ok")
     */
    bool ok() const;
    
    /**
     * @brief Check if this is an error response
     */
    bool isError() const { return !m_errorMessage.isEmpty(); }

    /**
     * @brief Get HTTP status code
     */
    int httpCode() const { return m_httpCode; }

    /**
     * @brief Get the raw JSON object
     */
    QJsonObject json() const { return m_json; }

    /**
     * @brief Get response as QVariant (for QML compatibility)
     */
    QVariant toVariant() const;

    /**
     * @brief Get a specific field from the response
     */
    QJsonValue operator[](const QString& key) const { return m_json[key]; }
    
    /**
     * @brief Get string value by key
     */
    QString string(const QString& key) const { return m_json[key].toString(); }
    
    /**
     * @brief Get int value by key
     */
    int integer(const QString& key) const { return m_json[key].toInt(); }
    
    /**
     * @brief Get bool value by key
     */
    bool boolean(const QString& key) const { return m_json[key].toBool(); }
    
    /**
     * @brief Get array value by key
     */
    QJsonArray array(const QString& key) const { return m_json[key].toArray(); }
    
    /**
     * @brief Get object value by key
     */
    QJsonObject object(const QString& key) const { return m_json[key].toObject(); }

    /**
     * @brief Get error message (if any)
     */
    QString errorMessage() const;

    /**
     * @brief Get error type from response
     */
    QString errorType() const { return m_json["error_type"].toString(); }

    /**
     * @brief Check for specific error conditions
     */
    bool isLoginRequired() const;
    bool isTwoFactorRequired() const;
    bool isChallengeRequired() const;
    bool isCheckpointRequired() const;
    bool isThrottled() const;

    /**
     * @brief Get the raw response data
     */
    QByteArray rawData() const { return m_rawData; }

private:
    QByteArray m_rawData;
    QJsonObject m_json;
    int m_httpCode;
    QString m_errorMessage;
};

} // namespace IG

#endif // INSTAGRAM_RESPONSE_H
