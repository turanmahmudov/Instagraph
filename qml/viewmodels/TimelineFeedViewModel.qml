import QtQuick 2.12
import Instagram 1.0

/**
 * TimelineFeedViewModel - ViewModel for HomePage timeline feed
 * 
 * Handles HomePage-specific logic:
 * - Timeline feed loading with seen posts tracking
 * - Stories feed tray
 * - User suggestions
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    // HomePage-specific properties
    property var seenPosts: []
    property ListModel suggestionsModel: ListModel {}
    property bool isPullToRefresh: true
    property bool clearModels: true
    
    // End of feed state
    property bool isCaughtUp: false
    property string caughtUpTitle: ""
    property string caughtUpSubtitle: ""
    property bool inSuggestedPostsSection: false

    // Stories tray state (persists across page navigation)
    property ListModel storiesTrayModel: ListModel {}
    property var storiesTrayAllUsers: []
    property bool storiesTrayLoaded: false

    /**
     * Load timeline feed
     * @param refresh - If true, clears feed and loads from beginning
     */
    function loadFeed(refresh) {
        setLoadingState(true)
        clearModels = false

        if (refresh || !nextMaxId) {
            feedModel.clear()
            nextMaxId = ""
            clearModels = true
            isCaughtUp = false
            inSuggestedPostsSection = false
        }

        instagram.getTimelineFeed(nextMaxId, seenPosts.join(','), isPullToRefresh)
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        // Block loading if we've reached suggestions or caught up
        if (inSuggestedPostsSection || isCaughtUp) {
            return
        }
        
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false)
        }
    }

    // Worker for processing timeline feed data
    WorkerScript {
        id: worker
        source: "../js/Workers/HomeFeedWorker.js"
        onMessage: {
            if (messageObject.type === "seen_posts") {
                seenPosts.push(messageObject.id)
            } else if (messageObject.type === "end_of_feed") {
                // Handle end of feed demarcator - block further loading
                if (messageObject.style === "top_of_feed") {
                    // Suggestions section - stop auto-loading
                    inSuggestedPostsSection = true
                } else if (messageObject.style === "hidden") {
                    // Caught up - stop auto-loading
                    isCaughtUp = true
                    caughtUpTitle = messageObject.title
                    caughtUpSubtitle = messageObject.subtitle
                }
            } else if (messageObject.type === "done") {
                // Worker finished processing - now it's safe to allow pagination
                nextComing = false
            }
        }
    }

    // Stories tray worker
    WorkerScript {
        id: trayWorker
        source: "../js/Workers/SimpleWorker.js"
        onMessage: {
        }
    }

    function loadStoriesTray(force) {
        if (!storiesTrayLoaded || force) {
            instagram.getReelsTrayFeed()
        }
    }

    // Connection to Instagram API
    Connections {
        target: instagram
        onTimelineFeedDataReady: {
            var data = JSON.parse(answer)
            handleFeedResponse(data)
        }
        onReelsTrayFeedDataReady: {
            var data = JSON.parse(answer)
            trayWorker.sendMessage({'feed': 'StoriesTray', 'obj': data.tray, 'model': storiesTrayModel, 'clear_model': true})
            storiesTrayLoaded = true
            storiesTrayAllUsers = []
            for (var i = 0; i < data.tray.length; i++) {
                storiesTrayAllUsers.push(data.tray[i].user.pk)
            }
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load feed"))
            return
        }

        isPullToRefresh = false
        setLoadingState(false)

        isEmpty = false
        if (data.num_results === 0) {
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
        // Worker will set nextComing = false when done
        worker.sendMessage({
            feed_items: data.feed_items,
            feed_model: feedModel,
            suggestions_model: suggestionsModel,
            clear: clearModels
        })
    }
}
