import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.1
import QtMultimedia 5.4

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: commentspage

    property var photoId
    property var mediaUserId

    property var last_deleted_media_comment

    property var commentCaption

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Comments")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    function mediaCommentsDataFinished(data) {
        if (typeof data.caption != 'undefined' && data.caption) {
            data.caption.ctext = typeof data.caption != 'undefined' && data.caption ? data.caption.text : ""

            worker.sendMessage({'feed': 'CommentsPage', 'obj': [data.caption], 'model': mediaCommentsModel, 'clear_model': clear_models})
        } else {
            data.caption = '';

            worker.sendMessage({'feed': 'CommentsPage', 'obj': [], 'model': mediaCommentsModel, 'clear_model': clear_models})
        }

        commentCaption = data.caption;

        worker.sendMessage({'feed': 'CommentsPage', 'obj': data.comments, 'model': mediaCommentsModel})

        list_loading = false
    }

    function commentPostedFinished(data) {
        data.comment.ctext = data.comment.text;
        mediaCommentsModel.append(data.comment);

        addCommentField.text = '';
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getMediaComments();
    }

    function getMediaComments(next_id)
    {
        clear_models = false
        if (!next_id) {
            mediaCommentsModel.clear()
            clear_models = true
        }
        instagram.getMediaComments(photoId);
    }

    function postComment(text)
    {
        instagram.postComment(photoId, text);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: commentspage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: mediaCommentsModel
    }

    ListView {
        id: mediaCommentsList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: addCommentItem.top
            top: commentspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height*2
        model: mediaCommentsModel
        delegate: ListItem {
            id: mediaCommentsDelegate
            divider.visible: false
            height: entry_column.height + units.gu(2)

            property var removalAnimation

            leadingActions: ListItemActions {
                actions: [
                    Action {
                        visible: user.pk == my_usernameId || mediaUserId == my_usernameId ? true : false
                        iconName: "delete"
                        text: i18n.tr("Remove")
                        onTriggered: {
                            last_deleted_media_comment = index

                            instagram.deleteComment(photoId, pk);
                        }
                    }
                ]

                Connections {
                    target: instagram
                    onCommentDeleted: {
                        if (index == last_deleted_media_comment) {
                            console.log(answer)
                            var data = JSON.parse(answer)

                            removalAnimation.start()
                        }
                    }
                }
            }

            removalAnimation: SequentialAnimation {
                alwaysRunToEnd: true

                PropertyAction {
                    target: mediaCommentsDelegate
                    property: "ListView.delayRemove"
                    value: true
                }

                UbuntuNumberAnimation {
                    target: mediaCommentsDelegate
                    property: "height"
                    to: 0
                }

                PropertyAction {
                    target: mediaCommentsDelegate
                    property: "ListView.delayRemove"
                    value: false
                }
            }

            Column {
                id: entry_column
                spacing: units.gu(1)
                width: parent.width
                y: units.gu(1)

                Row {
                    spacing: units.gu(1)
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        width: units.gu(5)
                        height: width

                        UbuntuShape {
                            width: parent.width
                            height: width
                            radius: "large"

                            source: Image {
                                id: feed_user_profile_image
                                width: parent.width
                                height: width
                                source: status == Image.Error ? "../images/not_found_user.jpg" : user.profile_pic_url
                                fillMode: Image.PreserveAspectCrop
                                anchors.centerIn: parent
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }
                        }

                        Item {
                            width: activity.width
                            height: width
                            anchors.centerIn: parent
                            opacity: feed_user_profile_image.status == Image.Loading

                            Behavior on opacity {
                                UbuntuNumberAnimation {
                                    duration: UbuntuAnimation.SlowDuration
                                }
                            }

                            ActivityIndicator {
                                id: activity
                                running: true
                            }
                        }
                    }

                    Column {
                        width: parent.width - units.gu(11)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(0.5)

                        Text {
                            text: Helper.formatUser(user.username) + ' ' + Helper.formatString(ctext)
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                            onLinkActivated: {
                                Scripts.linkClick(link)
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: units.gu(2)

                            Label {
                                text: Helper.milisecondsToString(created_at)
                                fontSize: "small"
                                color: UbuntuColors.darkGrey
                                font.weight: Font.Light
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                id: comment_likes_count
                                visible: comment_like_c != 0
                                text: comment_like_c == 0 ? "" : (comment_like_c + i18n.tr(" likes"))
                                fontSize: "small"
                                font.weight: Font.Normal
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                visible: commentCaption.ctext != ctext
                                text: i18n.tr("Reply")
                                fontSize: "small"
                                font.weight: Font.Normal
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        addCommentField.forceActiveFocus();
                                        addCommentField.text = "@"+ user.username + " "
                                    }
                                }
                            }
                        }
                    }

                    LikeComponent {
                        id: comment_like_component
                        visible: commentCaption.ctext != ctext
                        width: commentCaption != ctext ? units.gu(4) : 0
                        height: units.gu(5)
                        commentId: pk
                        has_liked: has_liked_c
                        onLikedfinished: {
                            if (likedCommentId == pk) {
                                if (liked) {
                                    comment_like_c = comment_like_c + 1
                                    comment_likes_count.visible = true
                                    comment_likes_count.text = comment_like_c + i18n.tr(" likes")
                                } else {
                                    comment_like_c = comment_like_c - 1
                                    comment_likes_count.visible = comment_like_c == 0 ? false : true
                                    comment_likes_count.text = comment_like_c == 0 ? "" : (comment_like_c + i18n.tr(" likes"))
                                }
                            }
                        }
                    }
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && mediaCommentsModel.count == 0
            onRefresh: {
                list_loading = true
                getMediaComments()
            }
        }
    }

    Item {
        id: addCommentItem
        height: units.gu(5)
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        Row {
            width: parent.width
            spacing: units.gu(1)

            TextField {
                id: addCommentField
                width: parent.width - addCommentButton.width - units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: i18n.tr("Add a comment")
                onVisibleChanged: {
                    if (visible) {
                        forceActiveFocus()
                    }
                }
            }

            Button {
                id: addCommentButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.green
                text: i18n.tr("Send")
                onClicked: {
                    postComment(addCommentField.text)
                }
            }
        }
    }

    Connections{
        target: instagram
        onMediaCommentsDataReady: {
            var data = JSON.parse(answer);
            mediaCommentsDataFinished(data);
        }
        onCommentPosted: {
            var data = JSON.parse(answer);
            commentPostedFinished(data);
        }
    }
}
