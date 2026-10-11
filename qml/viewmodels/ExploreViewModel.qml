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

    property JsonListModel recentSearchesModel: SearchResultModel {}
    property JsonListModel searchUsersModel: SearchResultModel {}
    property JsonListModel searchTagsModel: SearchResultModel {}
    property JsonListModel searchPlacesModel: SearchResultModel {}

    feedModel: ExploreGridModel {}

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

    Connections {
        target: instagram
        function onExploreFeedDataReady(answer) {
            var data = feedModel.parseResponse(answer, ["sectional_items"]);
            handleFeedResponse(data);
        }
        function onRecentSearchesDataReady(answer) {
            fillSearchModel('recentSearches', answer, "recent", recentSearchesModel);
        }
        function onSearchUserDataReady(answer) {
            fillSearchModel('searchUsers', answer, "users", searchUsersModel);
        }
        function onSearchTagsDataReady(answer) {
            fillSearchModel('searchTags', answer, "results", searchTagsModel);
        }
        function onSearchPlacesDataReady(answer) {
            fillSearchModel('searchLocation', answer, "items", searchPlacesModel);
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

        feedModel.appendParsed("sectional_items", clearModels);

        nextComing = false;
    }

    function fillSearchModel(type, answer, itemsKey, model) {
        model.parseResponse(answer, [itemsKey]);
        model.appendParsed(itemsKey, true, {
            "type": type
        });
    }
}
