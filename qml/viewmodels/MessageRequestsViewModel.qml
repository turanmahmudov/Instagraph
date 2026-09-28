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

    function loadFeed() {
        setLoadingState(true);
        instagram.getPendingInbox();
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/DirectInboxWorker.js"
    }

    Connections {
        target: instagram
        function onPendingInboxDataReady(answer) {
            if (!isLoading) {
                return;
            }

            var data = JSON.parse(answer);
            if (!data || !data.inbox) {
                handleError(i18n.tr("Failed to load message requests"));
                return;
            }

            setLoadingState(false);

            var threads = data.inbox.threads || [];
            isEmpty = threads.length === 0;

            worker.sendMessage({
                items: threads,
                model: feedModel,
                clear: true,
                activeUserId: activeUsernameId,
                typeTexts: DirectTypeTexts.getDirectTypeTexts()
            });
        }
    }
}
