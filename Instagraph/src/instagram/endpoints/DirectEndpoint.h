#ifndef INSTAGRAM_DIRECTENDPOINT_H
#define INSTAGRAM_DIRECTENDPOINT_H

#include <QObject>
#include <QVariant>

namespace IG {

class ApiClient;

/**
 * @brief Handles all direct messaging API operations.
 * 
 * This endpoint manages:
 * - Inbox and thread retrieval
 * - Sending messages and likes
 * - Media sharing in DMs
 * - Marking threads as seen
 */
class DirectEndpoint : public QObject
{
    Q_OBJECT

public:
    explicit DirectEndpoint(ApiClient* client, QObject* parent = nullptr);

    // Inbox operations
    void getInbox(const QString& cursorId = "");
    void getPendingInbox();
    void getDirectThread(const QString& threadId, const QString& cursorId = "");

    // Recipients
    void getRecentRecipients();
    void getRankedRecipients(const QString& query = "");

    // Thread actions
    void markThreadSeen(const QString& threadId, const QString& threadItemId,
                        const QString& uuid, const QString& csrfToken);

    // Messaging
    void sendMessage(const QString& recipients, const QString& text, 
                     const QString& threadId, const QString& uuid);
    void sendLike(const QString& recipients, const QString& threadId, const QString& uuid);
    void shareMedia(const QString& mediaId, const QString& recipients, 
                    const QString& text, const QString& uuid);

Q_SIGNALS:
    void inboxReady(const QVariant& answer);
    void pendingInboxReady(const QVariant& answer);
    void directThreadReady(const QVariant& answer);
    void recentRecipientsReady(const QVariant& answer);
    void rankedRecipientsReady(const QVariant& answer);
    void threadMarkedSeen(const QVariant& answer);
    void messageReady(const QVariant& answer);
    void likeReady(const QVariant& answer);
    void shareReady(const QVariant& answer);
    void error(const QString& message);

private:
    ApiClient* m_client;
};

} // namespace IG

#endif // INSTAGRAM_DIRECTENDPOINT_H
