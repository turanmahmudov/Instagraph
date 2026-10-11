import QtQuick 2.12
import Instagram 1.0

import "../js/DirectTypeTexts.js" as DirectTypeTexts

/**
 * MessageRequestsViewModel - ViewModel for MessageRequestsPage
 *
 * Handles the pending direct inbox:
 * - Threads from people the user does not follow
 */
BaseFeedViewModel {
    id: viewModel

    feedModel: DirectInboxModel {}

    function loadFeed() {
        setLoadingState(true);
        instagram.getPendingInbox();
    }

    Connections {
        target: instagram
        function onPendingInboxDataReady(answer) {
            if (!isLoading) {
                return;
            }

            var data = feedModel.parseResponse(answer, ["inbox.threads"]);
            if (!data || !data.inbox) {
                handleError(i18n.tr("Failed to load message requests"));
                return;
            }

            setLoadingState(false);

            isEmpty = feedModel.countParsed("inbox.threads") === 0;

            feedModel.appendParsed("inbox.threads", true, {
                "activeUserId": activeUsernameId,
                "typeTexts": DirectTypeTexts.getDirectTypeTexts()
            });
        }
    }
}
