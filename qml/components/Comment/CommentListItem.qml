import QtQuick 2.12
import Lomiri.Components 1.3

import ".."

import "../../js/Helper.js" as Helper

ListItem {
    id: commentlistitem
    divider.visible: false
    height: layout.height

    property var removalAnimation
    property var mediaUserId

    signal commentDeleted(var pk)
    signal commentLiked(var pk)
    signal commentUnliked(var pk)
    signal replyClicked(string username)
    signal linkClicked(string link)

    function removeComment() {
        removalAnimation.start();
    }

    leadingActions: ListItemActions {
        actions: [
            Action {
                visible: user.pk == activeUsernameId || mediaUserId == activeUsernameId
                iconName: "delete"
                text: i18n.tr("Remove")
                onTriggered: commentDeleted(pk)
            }
        ]
    }

    removalAnimation: SequentialAnimation {
        alwaysRunToEnd: true

        PropertyAction {
            target: commentlistitem
            property: "ListView.delayRemove"
            value: true
        }

        LomiriNumberAnimation {
            target: commentlistitem
            property: "height"
            to: 0
        }

        PropertyAction {
            target: commentlistitem
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
            width: parent.width - commentLikeAction.width

            CircleImage {
                id: feed_user_profile_image
                width: units.gu(5)
                height: width
                source: typeof user.profile_pic_url !== 'undefined' ? user.profile_pic_url : "../../images/not_found_user.jpg"
            }

            Column {
                width: parent.width - units.gu(6)
                anchors.verticalCenter: parent.verticalCenter
                spacing: units.gu(0.5)

                Text {
                    text: Helper.formatUser(user.username) + ' ' + Helper.formatString(comment_text)
                    wrapMode: Text.WordWrap
                    width: parent.width
                    textFormat: Text.RichText
                    color: styleApp.common.textColor
                    onLinkActivated: commentlistitem.linkClicked(link)
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
                        visible: like_count > 0
                        text: like_count > 0 ? (like_count.toLocaleString() + i18n.tr(" likes")) : ""
                        fontSize: "small"
                        font.weight: Font.Normal
                        wrapMode: Text.WordWrap
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        visible: !is_caption
                        text: i18n.tr("Reply")
                        fontSize: "small"
                        font.weight: Font.Normal
                        wrapMode: Text.WordWrap
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: commentlistitem.replyClicked(user.username)
                        }
                    }
                }
            }
        }

        CommentLikeItem {
            id: commentLikeAction
            visible: !is_caption
            width: visible ? units.gu(4) : 0
            height: units.gu(5)
            SlotsLayout.position: SlotsLayout.Trailing

            is_liked: has_liked
            onLikeClicked: commentlistitem.commentLiked(pk)
            onUnlikeClicked: commentlistitem.commentUnliked(pk)
        }
    }
}
