import QtQuick 2.12
import Instagram 1.0

/**
 * DirectThreadViewModel - ViewModel for DirectThreadPage
 *
 * Handles direct thread logic:
 * - Thread items loading with cursor pagination (older items)
 * - Thread users and title
 * - Marking the thread seen
 * - Sending text messages and likes
 */
Item {
    id: viewModel
    visible: false

    property var threadId

    property ListModel threadModel: ListModel {}

    property var threadUsers: ({})
    property string threadTitle: i18n.tr("Direct")

    property bool isLoading: false
    property bool isSending: false

    property string nextCursor: ""
    property bool moreAvailable: true
    property bool nextComing: true
    property bool clearModels: true
    property bool firstLoad: true

    property string sentMessage: ""

    signal messageSent

    /**
     * Load thread items
     * @param cursor - Pass "" or undefined to refresh, or an oldest_cursor to load older items
     */
    function loadThread(cursor) {
        isLoading = true;
        clearModels = false;

        if (!cursor) {
            threadModel.clear();
            nextCursor = "";
            clearModels = true;
        }

        instagram.getDirectThread(threadId, cursor || "");
    }

    function loadMore() {
        if (nextCursor && moreAvailable && !nextComing && !isLoading) {
            loadThread(nextCursor);
        }
    }

    function sendMessage(text) {
        var trimmedText = text.trim();
        if (!trimmedText || isSending) {
            return;
        }

        isSending = true;
        sentMessage = trimmedText;

        instagram.directMessage(buildRecipientsString(), trimmedText, threadId);
    }

    function sendLike() {
        if (isSending) {
            return;
        }

        isSending = true;

        instagram.directLike(buildRecipientsString(), threadId);
    }

    function buildRecipientsString() {
        var quotedIds = [];
        for (var userId in threadUsers) {
            quotedIds.push('"' + userId + '"');
        }
        return quotedIds.join(',');
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/DirectThreadWorker.js"
        onMessage: threadModel.insert(0, messageObject)
    }

    Connections {
        target: instagram
        onDirectThreadDataReady: {
            var data = JSON.parse(answer);
            handleThreadResponse(data);
        }
        onDirectMessageDataReady: {
            var data = JSON.parse(answer);
            handleSentItem(data, {
                "item_type": "text",
                "text": sentMessage
            });
        }
        onDirectLikeDataReady: {
            var data = JSON.parse(answer);
            handleSentItem(data, {
                "item_type": "like"
            });
        }
    }

    /**
     * Process thread response from API
     * @param data - Parsed JSON response
     */
    function handleThreadResponse(data) {
        isLoading = false;

        if (!data || !data.thread) {
            console.warn("Invalid thread data received");
            return;
        }

        var thread = data.thread;

        if (thread.thread_id && thread.thread_id != threadId) {
            return;
        }

        if (firstLoad) {
            threadTitle = thread.thread_title !== "" ? thread.thread_title : (thread.inviter ? thread.inviter.username : i18n.tr("Direct"));

            var users = {};
            (thread.users || []).forEach(function (user) {
                users[user.pk] = user;
            });
            threadUsers = users;

            if (thread.items && thread.items.length > 0) {
                instagram.markThreadSeen(thread.thread_id, thread.items[0].item_id);
            }

            firstLoad = false;
        }

        // Prevent duplicate loading
        if (nextCursor !== "" && nextCursor === thread.oldest_cursor) {
            return;
        }

        nextCursor = thread.has_older === true ? thread.oldest_cursor : "";
        moreAvailable = thread.has_older === true;
        nextComing = true;

        worker.sendMessage({
            obj: thread.items || [],
            model: threadModel,
            clear_model: clearModels,
            insert: false
        });

        nextComing = false;
    }

    /**
     * Insert a sent text or like at the bottom of the thread
     * @param data - Parsed JSON response
     * @param item - Thread item fields of the sent item
     */
    function handleSentItem(data, item) {
        if (!isSending) {
            return;
        }

        isSending = false;

        if (!data || !data.payload) {
            console.warn("Failed to send direct item");
            return;
        }

        item.user_id = parseInt(activeUsernameId);
        item.item_id = data.payload.item_id;

        worker.sendMessage({
            obj: [item],
            model: threadModel,
            clear_model: false,
            insert: true
        });

        if (item.item_type === "text") {
            sentMessage = "";
            messageSent();
        }
    }
}
