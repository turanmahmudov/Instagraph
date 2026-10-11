import QtQuick 2.12
import Instagram 1.0

/**
 * DirectBadgeViewModel - ViewModel for the unread Direct count in Main
 *
 * Handles the unseen thread count:
 * - Refresh after login, a push for a new message, or a thread marked seen
 * - Unread thread count from the first inbox page
 */
Item {
    id: viewModel
    visible: false

    property int unseenCount: 0
    property bool isLoading: false

    function refresh() {
        isLoading = true;
        instagram.getInbox("");
    }

    function isThreadUnread(thread, viewerId) {
        var item = thread.last_permanent_item;
        if (!item || String(item.user_id) === String(viewerId)) {
            return false;
        }

        var seen = (thread.last_seen_at || {})[String(viewerId)];
        return !seen || Number(item.timestamp) > Number(seen.timestamp);
    }

    Connections {
        target: instagram
        function onInboxDataReady(answer) {
            if (!isLoading) {
                return;
            }

            isLoading = false;
            var data = JSON.parse(answer);
            if (!data || !data.inbox || !data.inbox.threads) {
                return;
            }

            unseenCount = data.inbox.threads.filter(function (thread) {
                return isThreadUnread(thread, activeUsernameId);
            }).length;
        }
        function onMarkThreadSeenDataReady(answer) {
            refresh();
        }
    }

    Connections {
        target: mainView
        function onDirectMessageNotified(igAction) {
            refresh();
        }
    }
}
