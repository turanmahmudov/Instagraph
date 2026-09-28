import QtQuick 2.12
import Instagram 1.0

/**
 * ExploreViewModel - ViewModel for ExploreFeedPage
 *
 * Handles explore and search logic:
 * - Explore feed loading with pagination
 * - Recent searches
 * - Account, tag and place search
 */
BaseFeedViewModel {
    id: viewModel

    property bool clearModels: true

    property ListModel recentSearchesModel: ListModel {}
    property ListModel searchUsersModel: ListModel {}
    property ListModel searchTagsModel: ListModel {}
    property ListModel searchPlacesModel: ListModel {}

    /**
     * Load explore feed
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

        instagram.getExploreFeed(nextMaxId);
    }

    /**
     * Load more items (pagination)
     */
    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            loadFeed(false);
        }
    }

    function loadRecentSearches() {
        instagram.recentSearches();
    }

    function search(keyword) {
        instagram.searchUser(keyword);
        instagram.searchTags(keyword);
        instagram.searchPlaces(keyword);
    }

    WorkerScript {
        id: exploreWorker
        source: "../js/Workers/ExploreWorker.js"
    }

    WorkerScript {
        id: searchWorker
        source: "../js/Workers/SearchWorker.js"
    }

    Connections {
        target: instagram
        function onExploreFeedDataReady(answer) {
            var data = JSON.parse(answer);
            handleFeedResponse(data);
        }
        function onRecentSearchesDataReady(answer) {
            var data = JSON.parse(answer);
            fillSearchModel('recentSearches', data.recent, recentSearchesModel);
        }
        function onSearchUserDataReady(answer) {
            var data = JSON.parse(answer);
            fillSearchModel('searchUsers', data.users, searchUsersModel);
        }
        function onSearchTagsDataReady(answer) {
            var data = JSON.parse(answer);
            fillSearchModel('searchTags', data.results, searchTagsModel);
        }
        function onSearchPlacesDataReady(answer) {
            var data = JSON.parse(answer);
            fillSearchModel('searchLocation', data.items, searchPlacesModel);
        }
    }

    /**
     * Process explore feed response from API
     * @param data - Parsed JSON response
     */
    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load explore feed"));
            return;
        }

        setLoadingState(false);

        // Prevent duplicate loading
        if (nextMaxId === data.next_max_id)
            return;
        nextMaxId = "";
        if (data.more_available === true) {
            nextMaxId = data.next_max_id || "";
        }

        moreAvailable = data.more_available;
        nextComing = true;

        exploreWorker.sendMessage({
            obj: data.sectional_items || [],
            model: feedModel,
            clear_model: clearModels
        });

        nextComing = false;
    }

    function fillSearchModel(type, items, model) {
        searchWorker.sendMessage({
            type: type,
            obj: items || [],
            model: model,
            clear_model: true
        });
    }
}
