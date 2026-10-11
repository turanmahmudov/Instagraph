import QtQuick 2.12
import Instagram 1.0

BaseFeedViewModel {
    id: viewModel

    feedModel: MediaFeedModel {}

    property string tag: ""
    property string tab: "top"
    property int page: 1
    property var nextMediaIds: []
    property bool clearModels: true

    function loadFeed(refresh) {
        setLoadingState(true);
        clearModels = false;

        if (refresh || page === 1) {
            feedModel.clear();
            nextMaxId = "";
            nextMediaIds = [];
            page = 1;
            clearModels = true;
        }

        instagram.getTagSectionFeed(tag, tab, page, nextMediaIds, nextMaxId);
    }

    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            page++;
            loadFeed(false);
        }
    }

    Connections {
        target: instagram
        function onTagSectionFeedDataReady(answer) {
            var data = feedModel.parseResponse(answer, ["sections"]);
            handleFeedResponse(data);
        }
    }

    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load tag feed"));
            return;
        }

        setLoadingState(false);

        isEmpty = false;

        if (feedModel.countSectionMedia("sections") === 0) {
            isEmpty = true;
            return;
        }

        if (nextMaxId === data.next_max_id)
            return;
        nextMaxId = data.next_max_id || "";
        moreAvailable = data.more_available === true;
        nextMediaIds = data.next_media_ids || [];
        nextComing = true;

        feedModel.appendParsed("sections", clearModels, {
            "sections": true
        });

        nextComing = false;
    }
}
