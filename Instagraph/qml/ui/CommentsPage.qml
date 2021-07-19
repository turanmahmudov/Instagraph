import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: commentspage

    property var photoId
    property var mediaUserId

    property var last_deleted_media_comment

    property var commentCaption

    property bool list_loading: false
    property bool clear_models: true

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    header: PageHeaderItem {
        title: i18n.tr("Comments")
    }

    function mediaCommentsDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = typeof data.next_min_id != 'undefined' ? data.next_min_id : "";
            more_available = typeof data.next_min_id != 'undefined'
            next_coming = true;

            if (typeof data.caption != 'undefined' && data.caption && mediaCommentsModel.count == 0) {
                data.caption.ctext = typeof data.caption != 'undefined' && data.caption ? data.caption.text : ""

                worker.sendMessage({'feed': 'CommentsPage', 'obj': [data.caption], 'model': mediaCommentsModel, 'clear_model': clear_models})
            } else {
                data.caption = '';

                worker.sendMessage({'feed': 'CommentsPage', 'obj': [], 'model': mediaCommentsModel, 'clear_model': clear_models})
            }

            commentCaption = data.caption;

            worker.sendMessage({'feed': 'CommentsPage', 'obj': data.comments, 'model': mediaCommentsModel})

            next_coming = false;
        }

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
            next_max_id = ""
            clear_models = true
        }
        instagram.getComments(photoId, next_id);
    }

    function postComment(text)
    {
        instagram.comment(photoId, text);
    }

    ListModel {
        id: mediaCommentsModel
    }

    ListView {
        id: mediaCommentsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: addCommentItem.top
            top: commentspage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getMediaComments(next_max_id)
            }
        }

        clip: true
        cacheBuffer: parent.height
        model: mediaCommentsModel
        delegate: ListItem {
            id: mediaCommentsDelegate
            divider.visible: false
            height: layout.height

            property var removalAnimation

            leadingActions: ListItemActions {
                actions: [
                    Action {
                        visible: user.pk === activeUsernameId || mediaUserId === activeUsernameId ? true : false
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
                        if (index === last_deleted_media_comment) {
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

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    spacing: units.gu(1)
                    width: parent.width - comment_like_component.width

                    CircleImage {
                        id: feed_user_profile_image
                        width: units.gu(5)
                        height: width
                        source: typeof user.profile_pic_url !== 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                    }

                    Column {
                        width: parent.width - units.gu(6)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: units.gu(0.5)

                        Text {
                            text: Helper.formatUser(user.username) + ' ' + Helper.formatString(ctext)
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                            color: styleApp.common.textColor
                            onLinkActivated: {
                                Scripts.linkClick(commentspage, link)
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: units.gu(2)

                            Label {
                                text: Helper.milisecondsToString(created_at)
                                fontSize: "small"
                                color: styleApp.common.text2Color
                                font.weight: Font.Light
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter
                                font.capitalization: Font.AllLowercase
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
                                visible: commentCaption.ctext !== ctext
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
                }

                LikeComponent {
                    id: comment_like_component
                    visible: commentCaption.ctext !== ctext
                    width: commentCaption.ctext !== ctext ? units.gu(4) : 0
                    height: units.gu(5)
                    commentId: pk
                    has_liked: has_liked_c
                    onLikedfinished: {
                        if (likedCommentId === pk) {
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

                    SlotsLayout.position: SlotsLayout.Trailing
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
