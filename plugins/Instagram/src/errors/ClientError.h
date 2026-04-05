#ifndef INSTAGRAM_CLIENTERROR_H
#define INSTAGRAM_CLIENTERROR_H

#include <QString>
#include <QVariantMap>

namespace IG {

class ClientError {
public:
    enum class Type {
        None,
        Unknown,
        Network,
        Timeout,
        Auth,
        LoginRequired,
        TwoFactorRequired,
        ChallengeRequired,
        CheckpointRequired,
        RateLimit,
        InvalidResponse,
        BadRequest,
        NotFound,
        Forbidden
    };

    ClientError();
    ClientError(Type type, const QString & message, int httpCode = 0);
    ClientError(Type type, const QString & message, const QString & rawResponse, int httpCode = 0);

    bool isError() const {
        return m_type != Type::None;
    }
    Type type() const {
        return m_type;
    }
    int httpCode() const {
        return m_httpCode;
    }
    QString message() const {
        return m_message;
    }
    QString rawResponse() const {
        return m_rawResponse;
    }
    QVariantMap details() const {
        return m_details;
    }

    void setDetails(const QVariantMap & details) {
        m_details = details;
    }
    void setTwoFactorInfo(const QVariantMap & info);
    void setChallengeInfo(const QVariantMap & info);

    static QString typeToString(Type type);

private:
    Type m_type;
    int m_httpCode;
    QString m_message;
    QString m_rawResponse;
    QVariantMap m_details;
};

} // namespace IG

#endif // INSTAGRAM_CLIENTERROR_H
