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

    feedModel: MediaFeedModel {}

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

    Connections {
        target: instagram
        function onMediaInfoReady(answer) {
            var data = feedModel.parseResponse(answer);
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

        feedModel.appendItems(data.items, true);
    }
}
