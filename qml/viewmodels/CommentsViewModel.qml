import QtQuick 2.12
import Instagram 1.0

/**
 * CommentsViewModel - ViewModel for CommentsPage
 *
 * Handles media comments logic:
 * - Comments loading with pagination (caption first)
 * - Posting, deleting, liking and unliking comments
 */
Item {
    id: viewModel
    visible: false

    property var mediaId

    property ListModel commentsModel: ListModel {}

    property bool isLoading: false

    property string nextMinId: ""
    property bool moreAvailable: true
    property bool nextComing: true
    property bool clearModels: true

    property var pendingCommentId: null

    signal commentPosted
    signal commentDeleted(var commentId)

    /**
     * Load comments
     * @param nextId - Pass "" or undefined to refresh, or a min_id to load the next page
     */
    function loadComments(nextId) {
        isLoading = true;
        clearModels = false;

        if (!nextId) {
            commentsModel.clear();
            nextMinId = "";
            clearModels = true;
        }

        instagram.getComments(mediaId, nextId || "");
    }

    function canLoadMore() {
        return moreAvailable && !nextComing;
    }

    function postComment(text) {
        instagram.comment(mediaId, text);
    }

    function deleteComment(commentId) {
        pendingCommentId = commentId;
        instagram.deleteComment(mediaId, commentId);
    }

    function likeComment(commentId) {
        pendingCommentId = commentId;
        instagram.likeComment(commentId);
    }

    function unlikeComment(commentId) {
        pendingCommentId = commentId;
        instagram.unlikeComment(commentId);
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/CommentsWorker.js"
    }

    Connections {
        target: instagram
        function onMediaCommentsDataReady(answer) {
            var data = JSON.parse(answer);
            handleCommentsResponse(data);
        }
        function onCommentPosted(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok" && data.comment) {
                worker.sendMessage({
                    is_caption: false,
                    items: [data.comment],
                    model: commentsModel,
                    clear: false
                });
                commentPosted();
            }
        }
        function onCommentDeleted(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok" && pendingCommentId !== null) {
                commentDeleted(pendingCommentId);
                pendingCommentId = null;
            }
        }
        function onCommentLiked(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok") {
                updateCommentLike(pendingCommentId, true);
            }
        }
        function onCommentUnliked(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok") {
                updateCommentLike(pendingCommentId, false);
            }
        }
    }

    /**
     * Process comments response from API
     * @param data - Parsed JSON response
     */
    function handleCommentsResponse(data) {
        isLoading = false;

        if (!data)
            return;

        // Prevent duplicate loading
        if (nextMinId !== "" && nextMinId === data.next_min_id)
            return;

        nextMinId = data.next_min_id || "";
        moreAvailable = typeof data.next_min_id !== 'undefined';
        nextComing = true;

        if (data.caption && commentsModel.count === 0) {
            worker.sendMessage({
                is_caption: true,
                items: [data.caption],
                model: commentsModel,
                clear: clearModels
            });
        } else if (clearModels) {
            commentsModel.clear();
        }

        worker.sendMessage({
            is_caption: false,
            items: data.comments || [],
            model: commentsModel,
            clear: false
        });

        nextComing = false;
    }

    function updateCommentLike(commentId, liked) {
        if (commentId === null)
            return;

        for (var i = 0; i < commentsModel.count; i++) {
            var comment = commentsModel.get(i);
            if (comment.pk === commentId) {
                commentsModel.setProperty(i, "has_liked", liked);
                commentsModel.setProperty(i, "like_count", Math.max(0, comment.like_count + (liked ? 1 : -1)));
                break;
            }
        }

        pendingCommentId = null;
    }
}
