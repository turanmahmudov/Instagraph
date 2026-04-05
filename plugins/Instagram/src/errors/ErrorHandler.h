#ifndef INSTAGRAM_ERRORHANDLER_H
#define INSTAGRAM_ERRORHANDLER_H

#include "ClientError.h"
#include <QJsonObject>
#include <QNetworkReply>

namespace IG {

class ErrorHandler {
public:
    static ClientError parseResponse(const QString & response, int httpCode = 200);
    static ClientError fromNetworkError(QNetworkReply::NetworkError error,
                                        const QString & errorString);
    static bool isSuccess(const QJsonObject & response);
    static bool isSuccess(const QString & response);
};

} // namespace IG

#endif // INSTAGRAM_ERRORHANDLER_H
