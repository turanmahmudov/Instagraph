import QtQuick 2.12
import Lomiri.Content 1.3

/**
 * DownloadMediaViewModel - ViewModel for downloading the files of one post
 *
 * Handles post downloads:
 * - Photo, video and carousel items to local files through MediaCache
 * - The content type for the export
 */
Item {
    id: viewModel
    visible: false

    property var pendingUrls: []
    property var localUrls: ({})
    property bool isDownloading: false
    property int contentType: ContentType.Pictures

    signal downloaded(var fileUrls, int contentType)
    signal downloadFailed

    /**
     * Download the media of a post
     * @param items - Array of { url, isVideo }
     */
    function download(items) {
        if (isDownloading || items.length === 0) {
            return;
        }

        var hasVideo = items.some(function (item) {
            return item.isVideo;
        });
        var hasPhoto = items.some(function (item) {
            return !item.isVideo;
        });
        contentType = hasVideo && hasPhoto ? ContentType.All : (hasVideo ? ContentType.Videos : ContentType.Pictures);

        pendingUrls = items.map(function (item) {
            return item.url;
        });
        localUrls = {};
        isDownloading = true;

        for (var i = 0; i < pendingUrls.length; i++) {
            var localUrl = mediaCache.fetch(pendingUrls[i]);
            if (localUrl) {
                localUrls[pendingUrls[i]] = localUrl;
            }
        }
        finishIfComplete();
    }

    function finishIfComplete() {
        for (var i = 0; i < pendingUrls.length; i++) {
            if (!localUrls[pendingUrls[i]]) {
                return;
            }
        }

        isDownloading = false;
        downloaded(pendingUrls.map(function (url) {
            return localUrls[url];
        }), contentType);
    }

    Connections {
        target: mediaCache
        enabled: viewModel.isDownloading
        function onFetched(url, fileUrl) {
            if (pendingUrls.indexOf(url) !== -1) {
                localUrls[url] = fileUrl;
                finishIfComplete();
            }
        }
        function onFailed(url) {
            if (pendingUrls.indexOf(url) !== -1) {
                isDownloading = false;
                downloadFailed();
            }
        }
    }
}
