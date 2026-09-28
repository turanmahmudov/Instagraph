import QtQuick 2.12
import Instagram 1.0

BaseFeedViewModel {
    id: viewModel

    property string locationId: ""
    property string tab: "ranked"
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

        instagram.getLocationSectionFeed(locationId, tab, page, nextMediaIds, nextMaxId);
    }

    function loadMore() {
        if (nextMaxId && moreAvailable && !nextComing && !isLoading) {
            page++;
            loadFeed(false);
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    Connections {
        target: instagram
        function onLocationSectionFeedDataReady(answer) {
            var data = JSON.parse(answer);
            handleFeedResponse(data);
        }
    }

    function handleFeedResponse(data) {
        if (!data) {
            handleError(i18n.tr("Failed to load location feed"));
            return;
        }

        setLoadingState(false);

        isEmpty = false;

        var items = extractItemsFromSections(data);
        if (!items || items.length === 0) {
            isEmpty = true;
            return;
        }

        if (nextMaxId === data.next_max_id)
            return;
        nextMaxId = data.next_max_id || "";
        moreAvailable = data.more_available === true;
        nextMediaIds = data.next_media_ids || [];
        nextComing = true;

        worker.sendMessage({
            feed: 'tagFeedPage',
            obj: items,
            model: feedModel,
            clear_model: clearModels
        });

        nextComing = false;
    }

    function extractItemsFromSections(data) {
        if (!data.sections || data.sections.length === 0) {
            return [];
        }

        var items = [];
        for (var i = 0; i < data.sections.length; i++) {
            var section = data.sections[i];
            if (section.layout_type !== "media_grid" && section.layout_type !== "one_by_two" && section.layout_type !== "two_by_two") {
                continue;
            }
            if (!section.layout_content || !section.layout_content.medias) {
                continue;
            }
            for (var j = 0; j < section.layout_content.medias.length; j++) {
                var media = section.layout_content.medias[j];
                if (media && media.media) {
                    items.push(media.media);
                }
            }
        }
        return items;
    }
}
