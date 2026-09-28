import QtQuick 2.12
import Instagram 1.0

/**
 * SinglePhotoViewModel - ViewModel for SinglePhoto
 *
 * Handles single media loading logic:
 * - Media info loading
 * - Pull-to-refresh
 */
BaseFeedViewModel {
    id: viewModel

    property var photoId

    signal mediaNotFound

    /**
     * Load media info
     */
    function loadFeed() {
        setLoadingState(true);
        feedModel.clear();

        instagram.getInfoMedia(photoId);
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    Connections {
        target: instagram
        function onMediaInfoReady(answer) {
            var data = JSON.parse(answer);
            handleMediaResponse(data);
        }
    }

    /**
     * Process media info response from API
     * @param data - Parsed JSON response
     */
    function handleMediaResponse(data) {
        if (!data || !data.items || data.items.length === 0) {
            setLoadingState(false);
            mediaNotFound();
            return;
        }

        if (data.items[0].id !== photoId && data.items[0].pk != photoId) {
            return;
        }

        setLoadingState(false);

        worker.sendMessage({
            feed: 'singlePhotoPage',
            obj: data.items,
            model: feedModel,
            clear_model: true
        });
    }
}
