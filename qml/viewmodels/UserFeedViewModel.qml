import QtQuick 2.12
import Instagram 1.0

/**
 * UserFeedViewModel - ViewModel for UserPage
 * 
 * Handles user profile feed loading logic:
 * - User feed (photos)
 * - Tagged photos feed
 * - Highlights feed
 * - User info
 */
BaseFeedViewModel {
    id: viewModel

    // User-specific properties
    property string userId: ""
    property var userData: null
    property bool clearModels: true
    
    // Additional models for user page
    property ListModel taggedPhotosModel: ListModel {}
    property ListModel highlightsModel: ListModel {}
    
    property var allHighlight: []

    // Separate pagination state for tagged photos
    property string taggedNextMaxId: ""
    property bool taggedMoreAvailable: true
    property bool taggedNextComing: false
    property bool taggedClearModels: true

    /**
     * Load user feed
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

        instagram.getUserFeed(userId, nextMaxId)
    }

    /**
     * Load more feed items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false)
        }
    }

    /**
     * Load tagged photos
     * @param refresh - If true, clears model and loads from beginning
     */
    function loadTags(refresh) {
        setLoadingState(true)
        taggedClearModels = false

        if (refresh || !taggedNextMaxId) {
            taggedPhotosModel.clear()
            taggedNextMaxId = ""
            taggedClearModels = true
        }

        instagram.getUserTags(userId, taggedNextMaxId)
    }

    /**
     * Load more tagged photos (pagination)
     */
    function loadMoreTags() {
        if (taggedNextMaxId && taggedMoreAvailable && !taggedNextComing && !isLoading) {
            loadTags(false)
        }
    }

    /**
     * Check if should load more tagged items based on scroll position
     */
    function shouldLoadMoreTags(contentY, contentHeight, viewHeight) {
        var distanceFromBottom = contentHeight - contentY - viewHeight
        return distanceFromBottom < viewHeight * paginationThreshold
            && taggedMoreAvailable
            && !taggedNextComing
            && !isLoading
            && taggedNextMaxId
    }

    /**
     * Load user info
     */
    function loadUserInfo() {
        instagram.getInfoById(userId)
    }

    /**
     * Load user highlights
     */
    function loadHighlights() {
        highlightsModel.clear()
        instagram.getUserHighlightFeed(userId)
    }

    // Worker for processing user feed data
    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
        onMessage: {
            // Worker processing complete
        }
    }

    // Worker for processing highlights
    WorkerScript {
        id: highlightsWorker
        source: "../js/Workers/SimpleWorker.js"
        onMessage: {
            // Worker processing complete
        }
    }

    // Connection to Instagram API
    Connections {
        target: instagram
        
        onUserFeedDataReady: {
            var data = JSON.parse(answer)
            if (data.status === "ok") {
                handleFeedResponse(data)
            } else {
                handleError(i18n.tr("Failed to load user feed"))
            }
        }
        
        onInfoByIdDataReady: {
            var data = JSON.parse(answer)
            if (data.user.pk == userId) {
                handleUserInfoResponse(data)
            }
        }
        
        onUserTagsDataReady: {
            var data = JSON.parse(answer)
            handleTaggedPhotosResponse(data)
        }
        
        onUserHighlightFeedDataReady: {
            var data = JSON.parse(answer)
            handleHighlightsResponse(data)
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load user feed"))
            return
        }

        setLoadingState(false)

        isEmpty = false
        if (data.num_results === 0) {
            isEmpty = true
            return
        }

        // Prevent duplicate loading
        if (nextMaxId === data.next_max_id) return

        nextMaxId = data.next_max_id || ""
        moreAvailable = data.more_available === true
        nextComing = true

        // Send data to worker for processing
        worker.sendMessage({
            feed: 'userPage',
            obj: data.items,
            model: feedModel,
            clear_model: clearModels
        })

        nextComing = false
    }

    /**
     * Process user info response
     * @param data - Parsed JSON response
     */
    function handleUserInfoResponse(data) {
        userData = data.user
        loadHighlights()
    }

    /**
     * Process tagged photos response
     * @param data - Parsed JSON response
     */
    function handleTaggedPhotosResponse(data) {
        if (taggedNextMaxId === data.next_max_id) return

        taggedNextMaxId = data.next_max_id || ""
        taggedMoreAvailable = data.more_available === true
        taggedNextComing = true

        worker.sendMessage({
            feed: 'userPage',
            obj: data.items,
            model: taggedPhotosModel,
            clear_model: taggedClearModels
        })

        taggedNextComing = false
        setLoadingState(false)
    }

    /**
     * Process highlights response
     * @param data - Parsed JSON response
     */
    function handleHighlightsResponse(data) {
        highlightsWorker.sendMessage({
            feed: 'UserHighlights',
            obj: data.tray,
            model: highlightsModel,
            clear_model: true
        })

        allHighlight = []
        for (var i = 0; i < data.tray.length; i++) {
            allHighlight.push(data.tray[i].id)
        }
    }
}
