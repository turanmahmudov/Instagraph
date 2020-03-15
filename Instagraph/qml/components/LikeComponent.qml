import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Item {

    signal likedfinished(bool liked, var likedCommentId)

    property var commentId
    property bool has_liked: false
    property var latest_like_request

    function commentLikeDataFinished(data) {
        if (commentId == latest_like_request) {
            if (data.status == "ok") {
                likedfinished(true, commentId)
                has_liked = true

                commentlikeicon.name = "like"
                commentlikeicon.color = UbuntuColors.red

                latest_like_request = 0
            }
        }
    }

    function commentUnLikeDataFinished(data) {
        if (commentId == latest_like_request) {
            if (data.status == "ok") {
                likedfinished(false, commentId)
                has_liked = false

                commentlikeicon.name = "unlike"
                commentlikeicon.color = "#000000"

                latest_like_request = 0
            }
        }
    }

    Icon {
        id: commentlikeicon
        anchors.centerIn: parent
        anchors.right: parent.right
        width: units.gu(2)
        height: width
        name: has_liked == true ? "like" : "unlike"
        color: has_liked == true ? UbuntuColors.red : theme.palette.disabled.baseText
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (has_liked) {
                latest_like_request = commentId
                instagram.unLikeComment(commentId);
            } else {
                latest_like_request = commentId
                instagram.likeComment(commentId);
            }
        }
    }

    Connections{
        target: instagram
        onCommentLiked: {
            var data = JSON.parse(answer);
            commentLikeDataFinished(data)
        }
        onCommentUnLiked: {
            var data = JSON.parse(answer);
            commentUnLikeDataFinished(data)
        }
    }
}
