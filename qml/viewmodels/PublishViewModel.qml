import QtQuick 2.12
import Instagram 1.0

/**
 * PublishViewModel - ViewModel for CameraCaptionPage
 *
 * Handles photo publishing:
 * - Photo upload and post
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

        instagram.postImage(String(imagePath).replace('file://', ''), caption, location, "", disableComments ? "1" : "0");
    }

    Connections {
        target: instagram
        function onImageUploadProgressDataReady(answer) {
            progress = answer;
        }
        function onImageConfigureDataReady(answer) {
            if (!isUploading) {
                return;
            }

            isUploading = false;

            var data = JSON.parse(answer);
            if (data.status === "ok" && data.media) {
                published(data.media.id);
            } else {
                errorMessage = data.message || i18n.tr("Could not post the photo.");
            }
        }
        function onUploadFailed(message) {
            if (isUploading) {
                isUploading = false;
                errorMessage = message;
            }
        }
    }
}
