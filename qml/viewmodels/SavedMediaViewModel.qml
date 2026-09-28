import QtQuick 2.12
import Instagram 1.0

/**
 * SavedMediaViewModel - ViewModel for SavedMediaPage
 *
 * Handles saved media feed loading logic:
 * - Saved media feed loading with pagination
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    // SavedMedia-specific properties
    property bool clearModels: true

    /**
     * Load saved media feed
     * @param refresh - If true, clears feed and loads from beginning
     */
    function loadFeed(refresh) {
        setLoadingState(true);
        clearModels = false;

        if (refresh || !nextMaxId) {
            feedModel.clear();
            nextMaxId = "";
            clearModels = true;
        }

        instagram.getSavedFeed(nextMaxId);
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    // Worker for processing saved media data
    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    // Connection to Instagram API
    Connections {
        target: instagram
        function onSavedFeedDataReady(answer) {
            var data = JSON.parse(answer);
            handleFeedResponse(data);
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load saved media"));
            return;
        }

        setLoadingState(false);

        isEmpty = false;
        if (data.num_results === 0) {
            isEmpty = true;
            return;
        }

        // Prevent duplicate loading
        if (nextMaxId === data.next_max_id)
            return;
        nextMaxId = "";
        if (data.more_available === true) {
            nextMaxId = data.next_max_id || "";
        }

        moreAvailable = data.more_available;
        nextComing = true;

        // Send data to worker for processing
        worker.sendMessage({
            feed: 'savedMediaPage',
            obj: data.items,
            model: feedModel,
            clear_model: clearModels
        });

        nextComing = false;
    }
}
