import QtQuick 2.12
import Instagram 1.0

/**
 * BaseUserListViewModel - Common state and logic for all user list pages
 *
 * This base component provides shared functionality for pages that display
 * lists of users (followers, followings, media likers, blocked users, etc.):
 * - User list model
 * - Loading states (isLoading)
 * - Pagination state (nextMaxId, moreAvailable, nextComing)
 * - Pull-to-refresh support
 *
 * Child ViewModels must:
 * - Set the `dataKey` property (e.g. "users", "blocked_list")
 * - Set `hasPagination` to true/false
 * - Implement load(nextId): call beginLoad(nextId), then the Instagram API call
 * - Pass the matching Instagram API signal to handleResponse(answer)
 */
Item {
    id: base
    visible: false  // ViewModels are not visual components

    // User list data
    property JsonListModel userListModel: UserListModel {}

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

    /**
     * Prepare the state for a load or refresh of the user list.
     * @param nextId - Pass "" or undefined to refresh from the start,
     *                 or a max_id string to load the next page.
     */
    function beginLoad(nextId) {
        isLoading = true;
        clearModels = false;

        if (!nextId) {
            userListModel.clear();
            nextMaxId = "";
            clearModels = true;
        }
    }

    /**
     * Handle API response. Connect your Instagram signal to call this.
     * @param answer - Raw JSON string from the Instagram API signal, or the parsed object
     */
    function handleResponse(answer) {
        if (!isLoading)
            return;
        var isJson = typeof answer === "string";
        var data = isJson ? userListModel.parseResponse(answer, [dataKey]) : answer;
        if (!data)
            return;
        isPullToRefresh = false;
        isLoading = false;

        if (hasPagination) {
            // Prevent duplicate loading
            if (nextMaxId === data.next_max_id)
                return;
            nextMaxId = typeof data.next_max_id !== 'undefined' ? data.next_max_id : "";
            moreAvailable = typeof data.next_max_id !== 'undefined';
            nextComing = true;
        }

        if (isJson) {
            if (!userListModel.hasParsed(dataKey))
                return;
            userListModel.appendParsed(dataKey, clearModels);
        } else {
            var items = data[dataKey];
            if (!items)
                return;
            userListModel.appendItems(items, clearModels);
        }

        nextComing = false;
        isLoading = false;
    }

    /**
     * Check if should load more items
     * @returns true if pagination should be triggered
     */
    function canLoadMore() {
        return hasPagination && moreAvailable && !nextComing && !isLoading;
    }

    /**
     * Reset to initial state
     */
    function reset() {
        userListModel.clear();
        nextMaxId = "";
        moreAvailable = true;
        nextComing = true;
        isLoading = false;
        isPullToRefresh = true;
        clearModels = true;
    }
}
