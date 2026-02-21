import QtQuick 2.12
import Instagram 1.0

/**
 * TagFeedViewModel - ViewModel for TagFeedPage
 * 
 * Handles tag feed loading logic:
 * - Tag feed loading with pagination
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    // Tag-specific properties
    property string tag: ""
    property bool clearModels: true

    /**
     * Load tag feed
     * @param refresh - If true, clears feed and loads from beginning
     */
    function loadFeed(refresh) {
        setLoadingState(true)
        clearModels = false

        if (refresh || !nextMaxId) {
            feedModel.clear()
            nextMaxId = ""
            clearModels = true
        }

        instagram.getTagFeed(tag, nextMaxId)
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false)
        }
    }

    // Worker for processing tag feed data
    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
        onMessage: {
            // Worker processing complete
        }
    }

    // Connection to Instagram API
    Connections {
        target: instagram
        onTagFeedDataReady: {
            var data = JSON.parse(answer)
            handleFeedResponse(data)
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load tag feed"))
            return
        }

        setLoadingState(false)

        isEmpty = false
        if (!data.items || data.items.length === 0) {
            isEmpty = true
            return
        }

        // Prevent duplicate loading
        if (nextMaxId === data.next_max_id) return

        nextMaxId = ""
        if (data.more_available === true) {
            nextMaxId = data.next_max_id || ""
        }

        moreAvailable = data.more_available
        nextComing = true

        // Send data to worker for processing
        worker.sendMessage({
            feed: 'tagFeedPage',
            obj: data.items,
            model: feedModel,
            clear_model: clearModels
        })

        nextComing = false
    }
}
