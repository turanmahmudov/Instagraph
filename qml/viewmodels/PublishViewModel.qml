import QtQuick 2.12
import Instagram 1.0

/**
 * PublishViewModel - ViewModel for PublishPage
 *
 * Handles publishing:
 * - Photo upload and post
 * - Video upload and post
 * - Upload progress
 * - Error message
 */
Item {
    id: viewModel
    visible: false

    property bool isUploading: false
    property real progress: 0
    property string errorMessage: ""

    signal published(var mediaId)

    /**
     * Upload and post a photo
     * @param imagePath - Local image path
     * @param caption - Post caption
     * @param location - Location object, or {} for none
     * @param disableComments - true to turn off commenting
     */
    function publish(imagePath, caption, location, disableComments) {
        if (isUploading) {
            return;
        }

        errorMessage = "";
        progress = 0;
        isUploading = true;

        instagram.postImage(decodeURIComponent(String(imagePath).replace('file://', '')), caption, location, "", disableComments ? "1" : "0");
    }

    /**
     * Upload and post a video
     * @param videoUrl - Local video file URL
     * @param coverPath - Local path of the cover image
     * @param width - Video width in pixels
     * @param height - Video height in pixels
     * @param durationMs - Video duration in milliseconds
     * @param caption - Post caption
     * @param location - Location object, or {} for none
     * @param disableComments - true to turn off commenting
     */
    function publishVideo(videoUrl, coverPath, width, height, durationMs, caption, location, disableComments) {
        if (isUploading) {
            return;
        }

        errorMessage = "";
        progress = 0;
        isUploading = true;

        instagram.postVideo(decodeURIComponent(String(videoUrl).replace('file://', '')), coverPath, width, height, durationMs, caption, location, disableComments ? "1" : "0");
    }

    Connections {
        target: instagram
        function onImageUploadProgressDataReady(answer) {
            progress = answer;
        }
        function onImageConfigureDataReady(answer) {
            handleConfigureResponse(JSON.parse(answer));
        }
        function onVideoConfigureDataReady(answer) {
            handleConfigureResponse(JSON.parse(answer));
        }
        function onUploadFailed(message) {
            if (isUploading) {
                isUploading = false;
                errorMessage = message;
            }
        }
    }

    function handleConfigureResponse(data) {
        if (!isUploading) {
            return;
        }

        isUploading = false;

        if (data.status === "ok" && data.media) {
            published(data.media.id);
        } else {
            errorMessage = data.message || i18n.tr("Could not post.");
        }
    }
}
