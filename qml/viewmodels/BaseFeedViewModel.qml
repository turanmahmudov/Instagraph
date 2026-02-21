import QtQuick 2.12

/**
 * BaseFeedViewModel - Common state and logic for all feed types
 * 
 * This base component provides shared functionality that all feed ViewModels need:
 * - Loading states (isLoading, isEmpty, hasError)
 * - Pagination state (nextMaxId, moreAvailable)
 * - Error handling
 * - Feed model
 * 
 * Child ViewModels must implement:
 * - loadFeed() function
 * - loadMore() function
 * - WorkerScript with appropriate source
 * - Connections with appropriate Instagram API signals
 */
Item {
    id: base
    visible: false  // ViewModels are not visual components

    // Constants
    readonly property real paginationThreshold: 2.0

    // Feed data
    property ListModel feedModel: ListModel {}

    // Loading states
    property bool isLoading: false
    property bool isEmpty: false
    property bool hasError: false
    property string errorMessage: ""

    // Pagination state
    property string nextMaxId: ""
    property bool moreAvailable: true
    property bool nextComing: true

    /**
     * Handle error state
     * @param message - Error message to display
     */
    function handleError(message) {
        hasError = true
        errorMessage = message
        isLoading = false
    }

    /**
     * Reset feed to initial state
     * Clears all data and error states
     */
    function resetFeed() {
        feedModel.clear()
        nextMaxId = ""
        moreAvailable = true
        nextComing = true
        isEmpty = false
        hasError = false
        errorMessage = ""
    }

    /**
     * Set loading state and clear errors
     * @param loading - Whether feed is currently loading
     */
    function setLoadingState(loading) {
        isLoading = loading
        if (loading) {
            hasError = false
        }
    }

    /**
     * Check if should load more items based on scroll position
     * @param contentY - Current scroll position
     * @param contentHeight - Total content height
     * @param viewHeight - Visible viewport height
     * @returns true if should trigger pagination
     */
    function shouldLoadMore(contentY, contentHeight, viewHeight) {
        var distanceFromBottom = contentHeight - contentY - viewHeight
        return distanceFromBottom < viewHeight * paginationThreshold 
            && moreAvailable 
            && !nextComing 
            && !isLoading 
            && nextMaxId
    }

    // Abstract functions that child ViewModels must implement:
    // function loadFeed(refresh) { }
    // function loadMore() { }
}
