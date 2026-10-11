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
 * - User id lookup by username
 */
BaseFeedViewModel {
    id: viewModel

    // User-specific properties
    property string userId: ""
    property var userData: null
    property bool clearModels: true
    property string pendingUsername: ""

    signal userIdResolved(var resolvedUserId)

    onUserIdChanged: {
        if (userId) {
            nextMaxId = "";
            moreAvailable = true;
            nextComing = true;
            feedModel.clear();
            taggedPhotosModel.clear();
            taggedNextMaxId = "";
            taggedMoreAvailable = true;
            taggedClearModels = true;
            highlightsModel.clear();
            allHighlight = [];
        }
    }

    // Additional models for user page
    property JsonListModel taggedPhotosModel: MediaFeedModel {}
    property JsonListModel highlightsModel: ReelTrayModel {}

    feedModel: MediaFeedModel {}

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
        setLoadingState(true);
        clearModels = false;

        if (refresh || !nextMaxId) {
            feedModel.clear();
            nextMaxId = "";
            clearModels = true;
        }

        instagram.getUserFeed(userId, nextMaxId);
    }

    /**
     * Load more feed items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    /**
     * Load tagged photos
     * @param refresh - If true, clears model and loads from beginning
     */
    function loadTags(refresh) {
        setLoadingState(true);
        taggedClearModels = false;

        if (refresh || !taggedNextMaxId) {
            taggedPhotosModel.clear();
            taggedNextMaxId = "";
            taggedClearModels = true;
        }

        instagram.getUserTags(userId, taggedNextMaxId);
    }

    /**
     * Load more tagged photos (pagination)
     */
    function loadMoreTags() {
        if (taggedNextMaxId && taggedMoreAvailable && !taggedNextComing && !isLoading) {
            loadTags(false);
        }
    }

    /**
     * Load user info
     */
    function loadUserInfo() {
        instagram.getInfoById(userId);
    }

    /**
     * Look up the user id for a username; emits userIdResolved
     */
    function resolveUsername(username) {
        pendingUsername = username;
        instagram.getInfoByName(username);
    }

    /**
     * Load user highlights
     */
    function loadHighlights() {
        highlightsModel.clear();
        instagram.getUserHighlightFeed(userId);
    }

    Connections {
        target: instagram

        function onUserFeedDataReady(answer) {
            var data = feedModel.parseResponse(answer, ["items"]);
            if (data.status === "ok" && (!data.user || data.user.pk == userId)) {
                handleFeedResponse(data);
            }
        }

        function onInfoByNameDataReady(answer) {
            if (!pendingUsername) {
                return;
            }

            pendingUsername = "";
            var data = JSON.parse(answer);
            if (data.user) {
                userIdResolved(data.user.pk);
            }
        }

        function onInfoByIdDataReady(answer) {
            var data = JSON.parse(answer);
            if (data.user.pk == userId) {
                handleUserInfoResponse(data);
            }
        }

        function onUserTagsDataReady(answer) {
            var data = taggedPhotosModel.parseResponse(answer, ["items"]);
            if (!userId || !data || !data.user || data.user.pk == userId) {
                handleTaggedPhotosResponse(data);
            }
        }

        function onUserHighlightFeedDataReady(answer) {
            var data = highlightsModel.parseResponse(answer, ["tray"]);
            if (!userId || !data || !data.user || data.user.pk == userId) {
                handleHighlightsResponse(data);
            }
        }
    }

    /**
     * Process feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load user feed"));
            return;
        }

        if (data.user && data.user.pk != userId) {
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
        nextMaxId = data.next_max_id || "";
        moreAvailable = data.more_available === true;
        nextComing = true;

        feedModel.appendParsed("items", clearModels);

        nextComing = false;
    }

    /**
     * Process user info response
     * @param data - Parsed JSON response
     */
    function handleUserInfoResponse(data) {
        userData = data.user;
        loadHighlights();
    }

    /**
     * Process tagged photos response
     * @param data - Parsed JSON response
     */
    function handleTaggedPhotosResponse(data) {
        if (taggedNextMaxId === data.next_max_id)
            return;
        taggedNextMaxId = data.next_max_id || "";
        taggedMoreAvailable = data.more_available === true;
        taggedNextComing = true;

        taggedPhotosModel.appendParsed("items", taggedClearModels);

        taggedNextComing = false;
        setLoadingState(false);
    }

    /**
     * Process highlights response
     * @param data - Parsed JSON response
     */
    function handleHighlightsResponse(data) {
        highlightsModel.appendParsed("tray", true);

        allHighlight = [];
        for (var i = 0; i < highlightsModel.count; i++) {
            allHighlight.push(highlightsModel.get(i).id);
        }
    }
}
