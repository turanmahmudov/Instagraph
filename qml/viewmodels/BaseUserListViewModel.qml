import QtQuick 2.12

/**
 * BaseUserListViewModel - Common state and logic for all user list pages
 *
 * This base component provides shared functionality for pages that display
 * lists of users (followers, followings, media likers, blocked users, etc.):
 * - User list model
 * - Loading states (isLoading)
 * - Pagination state (nextMaxId, moreAvailable, nextComing)
 * - Pull-to-refresh support
 * - Worker-based model population via UserWorker.js
 *
 * Child pages must:
 * - Set the `dataKey` property (e.g. "users", "blocked_list")
 * - Set `hasPagination` to true/false
 * - Call loadData(apiCallFunction) to initiate loading
 * - Connect the appropriate Instagram API signal to handleResponse(answer)
 */
Item {
    id: base
    visible: false  // ViewModels are not visual components

    // User list data
    property ListModel userListModel: ListModel {}

    // Loading states
    property bool isLoading: false
    property bool isPullToRefresh: true

    // Pagination state
    property string nextMaxId: ""
    property bool moreAvailable: true
    property bool nextComing: true

    // Configuration - set by child or consuming page
    property string dataKey: "users"        // JSON key containing the user array
    property bool hasPagination: true       // Whether this list supports pagination

    // Internal
    property bool clearModels: true

    // Worker for processing user data into model
    WorkerScript {
        id: worker
        source: "../js/Workers/UserWorker.js"
    }

    /**
     * Load or refresh the user list.
     * @param nextId - Pass "" or undefined to refresh from the start,
     *                 or a max_id string to load the next page.
     * @param apiCall - A function that performs the actual Instagram API call.
     *                  Receives nextId as argument: function(nextId) { instagram.getFollowers(userId, nextId) }
     */
    function loadData(nextId, apiCall) {
        isLoading = true
        clearModels = false

        if (!nextId) {
            userListModel.clear()
            nextMaxId = ""
            clearModels = true
        }

        apiCall(nextId)
    }

    /**
     * Handle API response. Connect your Instagram signal to call this.
     * @param answer - Raw JSON string from the Instagram API signal
     */
    function handleResponse(answer) {
        var data = JSON.parse(answer)
        if (!data) return

        isPullToRefresh = false
        isLoading = false

        if (hasPagination) {
            // Prevent duplicate loading
            if (nextMaxId === data.next_max_id) return

            nextMaxId = typeof data.next_max_id !== 'undefined' ? data.next_max_id : ""
            moreAvailable = typeof data.next_max_id !== 'undefined'
            nextComing = true
        }

        var items = data[dataKey]
        if (!items) return

        worker.sendMessage({
            items: items,
            model: userListModel,
            clear: clearModels
        })

        nextComing = false
        isLoading = false
    }

    /**
     * Check if should load more items (for use in ListView.onMovementEnded)
     * @returns true if pagination should be triggered
     */
    function canLoadMore() {
        return hasPagination && moreAvailable && !nextComing
    }

    /**
     * Reset to initial state
     */
    function reset() {
        userListModel.clear()
        nextMaxId = ""
        moreAvailable = true
        nextComing = true
        isLoading = false
        isPullToRefresh = true
        clearModels = true
    }
}
