import QtQuick 2.12
import Instagram 1.0

import "../js/DirectTypeTexts.js" as DirectTypeTexts

/**
 * DirectInboxViewModel - ViewModel for DirectInboxPage
 *
 * Handles direct inbox loading logic:
 * - Inbox threads loading with cursor pagination
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    property bool clearModels: true

    /**
     * Load inbox threads
     * @param refresh - If true, clears threads and loads from beginning
     */
    function loadFeed(refresh) {
        setLoadingState(true);
        clearModels = false;

        if (refresh || !nextMaxId) {
            feedModel.clear();
            nextMaxId = "";
            clearModels = true;
        }

        instagram.getInbox(nextMaxId);
    }

    /**
     * Load older threads (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/DirectInboxWorker.js"
    }

    Connections {
        target: instagram
        function onInboxDataReady(answer) {
            var data = JSON.parse(answer);
            handleInboxResponse(data);
        }
    }

    /**
     * Process inbox response from API
     * @param data - Parsed JSON response
     */
    function handleInboxResponse(data) {
        if (!data || !data.inbox) {
            handleError(i18n.tr("Failed to load inbox"));
            return;
        }

        setLoadingState(false);

        isEmpty = false;
        if (data.inbox.threads.length === 0) {
            isEmpty = true;
            return;
        }

        // Prevent duplicate loading
        if (nextMaxId === data.inbox.oldest_cursor)
            return;
        nextMaxId = "";
        if (data.inbox.has_older === true) {
            nextMaxId = data.inbox.oldest_cursor;
        }

        moreAvailable = data.inbox.has_older;
        nextComing = true;

        worker.sendMessage({
            items: data.inbox.threads,
            model: feedModel,
            clear: clearModels,
            activeUserId: activeUsernameId,
            typeTexts: DirectTypeTexts.getDirectTypeTexts()
        });

        nextComing = false;
    }
}
