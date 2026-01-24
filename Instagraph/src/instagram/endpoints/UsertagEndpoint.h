#ifndef INSTAGRAM_USERTAGENDPOINT_H
#define INSTAGRAM_USERTAGENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all usertag-related API operations.
 */
class UsertagEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit UsertagEndpoint(ApiClient* client, QObject* parent = nullptr);

    void getUserTags(const QString& userId, const QString& maxId = "", 
                     const QString& minTimestamp = "", const QString& rankToken = "");
    void removeSelfTag(const QString& mediaId);

Q_SIGNALS:
    void userTagsReady(const QVariant& answer);
    void selfTagRemoved(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_USERTAGENDPOINT_H
