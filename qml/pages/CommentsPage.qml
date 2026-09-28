import QtQuick 2.12
import Lomiri.Components 1.3

import "../js/Scripts.js" as Scripts

import "../components"
import "../components/Page"
import "../components/Comment"
import "../viewmodels"

PageItem {
    id: commentspage

    header: PageHeaderItem {
        title: i18n.tr("Comments")
    }

    property var photoId
    property var mediaUserId

    CommentsViewModel {
        id: viewModel
        mediaId: commentspage.photoId
        onCommentPosted: addCommentItem.clear()
    }

    property alias list_loading: viewModel.isLoading

    ListView {
        id: mediaCommentsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: addCommentItem.top
            top: commentspage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && viewModel.canLoadMore()) {
                viewModel.loadComments(viewModel.nextMinId);
            }
        }

        clip: true
        cacheBuffer: parent.height
        model: viewModel.commentsModel
        delegate: CommentListItem {
            id: commentDelegate
            mediaUserId: commentspage.mediaUserId
            onCommentDeleted: viewModel.deleteComment(pk)
            onCommentLiked: viewModel.likeComment(pk)
            onCommentUnliked: viewModel.unlikeComment(pk)
            onReplyClicked: addCommentItem.prepareReply(username)
            onLinkClicked: Scripts.linkClick(commentspage, link)

            Connections {
                target: viewModel
                onCommentDeleted: {
                    if (commentId === pk) {
                        commentDelegate.removeComment();
                    }
                }
            }
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.commentsModel.count == 0
            onRefresh: {
                viewModel.loadComments();
            }
        }
    }

    AddCommentItem {
        id: addCommentItem
        height: units.gu(5)
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        onCommentPosted: viewModel.postComment(text)
    }

    Component.onCompleted: {
        viewModel.loadComments();
    }
}
