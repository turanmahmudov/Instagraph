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
    property JsonListModel suggestionsModel: UserListModel {}
    property bool isPullToRefresh: true
    property bool clearModels: true

    // End of feed state
    property bool isCaughtUp: false
    property string caughtUpTitle: ""
    property string caughtUpSubtitle: ""
    property bool inSuggestedPostsSection: false

    // Stories tray state (persists across page navigation)
    property JsonListModel storiesTrayModel: ReelTrayModel {}
    property var storiesTrayAllUsers: []
    property bool storiesTrayLoaded: false

    /**
     * Load timeline feed
     * @param refresh - If true, clears feed and loads from beginning
     */
    function loadFeed(refresh) {
        setLoadingState(true);
        clearModels = false;

        if (refresh || !nextMaxId) {
            feedModel.clear();
            nextMaxId = "";
            clearModels = true;
            isCaughtUp = false;
            inSuggestedPostsSection = false;
        }

        instagram.getTimelineFeed(nextMaxId, seenPosts.join(','), isPullToRefresh);
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        // Block loading if we've reached suggestions or caught up
        if (inSuggestedPostsSection || isCaughtUp) {
            return;
        }

        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    feedModel: TimelineFeedModel {
        suggestionsModel: viewModel.suggestionsModel
    }

    function loadStoriesTray(force) {
        if (!storiesTrayLoaded || force) {
            instagram.getReelsTrayFeed();
        }
    }

    // Connection to Instagram API
    Connections {
        target: instagram
        function onTimelineFeedDataReady(answer) {
            var data = feedModel.parseResponse(answer, ["feed_items"]);
            handleFeedResponse(data);
        }
        function onReelsTrayFeedDataReady(answer) {
            storiesTrayModel.parseResponse(answer, ["tray"]);
            storiesTrayModel.appendParsed("tray", true, {
                "stringIds": true
            });
            storiesTrayLoaded = true;
            storiesTrayAllUsers = [];
            for (var i = 0; i < storiesTrayModel.count; i++) {
                storiesTrayAllUsers.push(storiesTrayModel.get(i).user.pk);
            }
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load feed"));
            return;
        }

        isPullToRefresh = false;
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

        var feedExtras = feedModel.appendParsed("feed_items", clearModels);
        for (var i = 0; i < feedExtras.seenPosts.length; i++) {
            seenPosts.push(feedExtras.seenPosts[i]);
        }
        for (var j = 0; j < feedExtras.endOfFeed.length; j++) {
            var endOfFeed = feedExtras.endOfFeed[j];
            // Handle end of feed demarcator - block further loading
            if (endOfFeed.style === "top_of_feed") {
                // Suggestions section - stop auto-loading
                inSuggestedPostsSection = true;
            } else if (endOfFeed.style === "hidden") {
                // Caught up - stop auto-loading
                isCaughtUp = true;
                caughtUpTitle = endOfFeed.title;
                caughtUpSubtitle = endOfFeed.subtitle;
            }
        }
        nextComing = false;
    }
}
