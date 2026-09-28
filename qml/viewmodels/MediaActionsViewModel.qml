import QtQuick 2.12
import Instagram 1.0

/**
 * MediaActionsViewModel - ViewModel for the actions on one media entry
 *
 * Handles the actions of MediaEntry:
 * - Like and unlike
 * - Save and unsave
 * - Delete, remove the self tag
 * - Enable and disable comments
 */
Item {
    id: viewModel
    visible: false

    property var mediaId
    property var pendingActionId: null
    property var pendingDeleteId: null

    signal likeUpdated(bool liked)
    signal saveUpdated(bool saved)
    signal commentsUpdated(bool disabled)
    signal deleted
    signal selfTagRemoved

    function like() {
        pendingActionId = mediaId;
        instagram.like(mediaId);
    }

    function unlike() {
        pendingActionId = mediaId;
        instagram.unLike(mediaId);
    }

    function save() {
        pendingActionId = mediaId;
        instagram.saveMedia(mediaId);
    }

    function unsave() {
        pendingActionId = mediaId;
        instagram.unsaveMedia(mediaId);
    }

    function enableComments() {
        pendingActionId = mediaId;
        instagram.enableMediaComments(mediaId);
    }

    function disableComments() {
        pendingActionId = mediaId;
        instagram.disableMediaComments(mediaId);
    }

    function deleteMedia() {
        pendingDeleteId = mediaId;
        instagram.deleteMedia(mediaId);
    }

    function removeSelfTag() {
        pendingDeleteId = mediaId;
        instagram.removeSelftag(mediaId);
    }

    function takeActionResponse(answer) {
        if (pendingActionId !== mediaId) {
            return false;
        }

        pendingActionId = null;
        return JSON.parse(answer).status === "ok";
    }

    Connections {
        target: instagram
        enabled: viewModel.pendingActionId !== null || viewModel.pendingDeleteId !== null

        function onMediaDeleted(answer) {
            if (pendingDeleteId !== mediaId) {
                return;
            }

            pendingDeleteId = null;
            if (JSON.parse(answer).did_delete) {
                deleted();
            }
        }

        function onRemoveSelftagDone(answer) {
            if (pendingDeleteId !== mediaId) {
                return;
            }

            pendingDeleteId = null;
            if (JSON.parse(answer).status === "ok") {
                selfTagRemoved();
            }
        }

        function onEnableMediaCommentsDataReady(answer) {
            if (takeActionResponse(answer)) {
                commentsUpdated(false);
            }
        }

        function onDisableMediaCommentsDataReady(answer) {
            if (takeActionResponse(answer)) {
                commentsUpdated(true);
            }
        }

        function onLikeDataReady(answer) {
            if (takeActionResponse(answer)) {
                likeUpdated(true);
            }
        }

        function onUnLikeDataReady(answer) {
            if (takeActionResponse(answer)) {
                likeUpdated(false);
            }
        }

        function onSaveMediaDataReady(answer) {
            if (takeActionResponse(answer)) {
                saveUpdated(true);
            }
        }

        function onUnsaveMediaDataReady(answer) {
            if (takeActionResponse(answer)) {
                saveUpdated(false);
            }
        }
    }
}
