import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

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

                commentlikeicon.name = "\ueadf"
                commentlikeicon.color = LomiriColors.red

                latest_like_request = 0
            }
        }
    }

    function commentUnLikeDataFinished(data) {
        if (commentId == latest_like_request) {
            if (data.status == "ok") {
                likedfinished(false, commentId)
                has_liked = false

                commentlikeicon.name = "\ueae1"
                commentlikeicon.color = styleApp.common.iconActiveColor

                latest_like_request = 0
            }
        }
    }

    LineIcon {
        id: commentlikeicon
        anchors.centerIn: parent
        anchors.right: parent.right
        name: has_liked === true ? "\ueadf" : "\ueae1"
        color: has_liked === true ? LomiriColors.red : styleApp.common.iconActiveColor
        iconSize: units.gu(2.2)
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
        onCommentUnliked: {
            var data = JSON.parse(answer);
            commentUnLikeDataFinished(data)
        }
    }
}
