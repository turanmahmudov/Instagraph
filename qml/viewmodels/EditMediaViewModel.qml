import QtQuick 2.12
import Instagram 1.0

import "../js/Helper.js" as Helper

/**
 * EditMediaViewModel - ViewModel for EditMediaPage
 *
 * Handles post caption editing:
 * - Media info loading (image and caption)
 * - Caption save
 */
Item {
    id: viewModel
    visible: false

    property var mediaId

    property var imageCandidates: []
    property string caption: ""

    property bool isSaving: false

    signal mediaSaved

    function loadMedia() {
        instagram.getInfoMedia(mediaId);
    }

    /**
     * Save a new caption
     * @param text - Caption text
     */
    function saveCaption(text) {
        if (isSaving) {
            return;
        }

        isSaving = true;
        instagram.editMedia(mediaId, text);
    }

    Connections {
        target: instagram
        function onMediaInfoReady(answer) {
            var data = JSON.parse(answer);
            if (!data.items || data.items.length === 0 || data.items[0].id !== mediaId) {
                return;
            }

            var media = data.items[0];
            imageCandidates = media.image_versions2 ? media.image_versions2.candidates : [];
            caption = media.caption ? media.caption.text : "";
        }
        function onMediaEdited(answer) {
            if (!isSaving) {
                return;
            }

            isSaving = false;

            var data = JSON.parse(answer);
            if (data.status === "ok") {
                mediaSaved();
            }
        }
        function onError(message) {
            isSaving = false;
        }
    }
}
