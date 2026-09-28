import QtQuick 2.12
import Instagram 1.0

/**
 * LikedMediaViewModel - ViewModel for LikedMediaPage
 *
 * Handles liked media feed loading logic:
 * - Liked media feed loading with pagination
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    property bool clearModels: true

    /**
     * Load liked media feed
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

        instagram.getLikedMedia(nextMaxId);
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    Connections {
        target: instagram
        function onLikedMediaDataReady(answer) {
            var quotedAnswer = answer.replace(/([\[:])?(\d{18,})([,\}\]])/g, "$1\"$2\"$3");
            var data = JSON.parse(quotedAnswer);
            handleFeedResponse(data);
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load liked media"));
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

        worker.sendMessage({
            feed: 'likedMediaPage',
            obj: data.items,
            model: feedModel,
            clear_model: clearModels
        });

        nextComing = false;
    }
}
