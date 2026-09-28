import QtQuick 2.12
import Instagram 1.0

/**
 * RecipientsViewModel - ViewModel for direct message recipients
 *
 * Handles recipient logic:
 * - Ranked recipients loading and search
 * - Sending a message, a like or a shared post to the selected users
 *
 * Used by NewDirectMessagePage and ShareMediaPage.
 */
Item {
    id: viewModel
    visible: false

    property ListModel recipientsModel: ListModel {}

    /**
     * Load ranked recipients
     * @param query - Search text, or "" for the default ranking
     */
    function loadRecipients(query) {
        instagram.getRankedRecipients(query || "");
    }

    /**
     * Send a text message to new recipients
     * @param userIds - Array of user ids
     * @param text - Message text
     */
    function sendMessage(userIds, text) {
        instagram.directMessage(buildRecipientsString(userIds), text, "");
    }

    /**
     * Send a like to new recipients
     * @param userIds - Array of user ids
     */
    function sendLike(userIds) {
        instagram.directLike(buildRecipientsString(userIds), "");
    }

    /**
     * Share a post with the recipients
     * @param mediaId - Id of the shared post
     * @param userIds - Array of user ids
     * @param text - Message text
     */
    function shareMedia(mediaId, userIds, text) {
        instagram.directShare(mediaId, buildRecipientsString(userIds), text);
    }

    /**
     * Build the recipients argument for direct message calls
     * @param userIds - Array of user ids
     * @returns Comma separated list of quoted user ids
     */
    function buildRecipientsString(userIds) {
        var quotedIds = [];
        for (var i in userIds) {
            quotedIds.push('"' + userIds[i] + '"');
        }
        return quotedIds.join(',');
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/SimpleWorker.js"
    }

    Connections {
        target: instagram
        function onRankedRecipientsDataReady(answer) {
            var data = JSON.parse(answer);
            worker.sendMessage({
                feed: 'ShareMediaPage',
                obj: data.ranked_recipients || [],
                model: recipientsModel,
                clear_model: true
            });
        }
    }
}
