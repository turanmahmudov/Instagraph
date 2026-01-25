import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: directinboxpage

    property bool list_loading: false

    property bool isEmpty: false

    property string next_oldest_cursor_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    header: PageHeaderItem {
        title: i18n.tr("Direct")
        trailingActions: [
            Action {
                id: newDirectMessageAction
                text: i18n.tr("New Message")
                iconName: "\ueb48"
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("NewDirectMessagePage.qml"))
                }
            }
        ]
    }

    function inboxDataFinished(data) {
        if (data.inbox.threads.length == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_oldest_cursor_id == data.inbox.oldest_cursor) {
            return false;
        } else {
            next_oldest_cursor_id = data.inbox.has_older == true ? data.inbox.oldest_cursor : "";
            more_available = data.inbox.has_older;
            next_coming = true;

            for (var i = 0; i < data.inbox.threads.length; i++) {
                data.inbox.threads[i].user_profile_pic_url = typeof data.inbox.threads[i].users[0] != 'undefined' ? data.inbox.threads[i].users[0].profile_pic_url : data.inbox.threads[i].inviter.profile_pic_url;
                data.inbox.threads[i].item_timestamp = data.inbox.threads[i].items[0].timestamp;
                v2InboxModel.append(data.inbox.threads[i]);
            }

            next_coming = false;
        }

        list_loading = false
    }

    Component.onCompleted: {
        getInbox();
    }

    function getInbox(oldest_cursor_id)
    {
        clear_models = false
        if (!oldest_cursor_id) {
            v2InboxModel.clear()
            next_oldest_cursor_id = 0
            clear_models = true
        }
        instagram.getInbox(oldest_cursor_id);
    }

    ListModel {
        id: v2InboxModel
        dynamicRoles: true
    }

    ListView {
        id: v2InboxList
        visible: !isEmpty
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            top: directinboxpage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getInbox(next_oldest_cursor_id)
            }
        }

        clip: true
        cacheBuffer: parent.height
        model: v2InboxModel
        delegate: ListItem {
            id: userFollowersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToNext(directinboxpage, Qt.resolvedUrl("DirectThreadPage.qml"), {threadId: thread_id});
            }

            property bool unseen: last_permanent_item.timestamp > last_seen_at[Object.keys(last_seen_at)[0]].timestamp

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: parent.width - unseen_mark.width

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: user_profile_pic_url
                    }

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: thread_title != "" ? thread_title : inviter.username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            color: styleApp.common.textColor
                            width: parent.width
                        }

                        Text {
                            property string item_text: last_permanent_item.item_type === 'media_share' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You shared a post") : i18n.tr("Shared a post")) :
                                                       last_permanent_item.item_type === 'media' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You shared a media") : i18n.tr("Shared a media")) :
                                                       last_permanent_item.item_type === 'story_share' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You sent a story") : i18n.tr("Sent a story")) :
                                                       last_permanent_item.item_type === 'link' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You shared a link") : i18n.tr("Shared a link")) :
                                                       last_permanent_item.item_type === 'like' ? last_permanent_item.like :
                                                       last_permanent_item.item_type === 'action_log' ? last_permanent_item.action_log.description :
                                                       last_permanent_item.item_type === 'placeholder' ? last_permanent_item.placeholder.title :
                                                       last_permanent_item.item_type === 'reel_share' ?
                                                            (last_permanent_item.reel_share.type == 'mention' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You mentioned their in a story") : i18n.tr("Mentioned you in a story")) :
                                                            last_permanent_item.reel_share.type == 'reply' ? (last_permanent_item.user_id == activeUsername ? i18n.tr("You replied to their story") : i18n.tr("Replied to your story")) : i18n.tr("UNKNOWN")) :
                                                       last_permanent_item.text
                            text: item_text
                            font.weight: typeof unseen != 'undefined' && unseen ? Font.DemiBold : Font.ExtraLight
                            width: parent.width
                            wrapMode: Text.WordWrap
                            maximumLineCount: 1
                            elide: Text.ElideRight
                            color: styleApp.common.textColor
                        }

                        Label {
                            id: item_time
                            text: Helper.milisecondsToString(last_permanent_item.timestamp, false, true)
                            fontSize: "small"
                            color: styleApp.common.text2Color
                            font.weight: Font.Light
                            font.capitalization: Font.AllLowercase
                        }
                    }
                }

                Rectangle {
                    id: unseen_mark
                    width: unseen ? units.gu(1) : 0
                    height: width
                    visible: unseen
                    radius: width/2
                    color: LomiriColors.blue

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && v2InboxModel.count == 0
            onRefresh: {
                list_loading = true
                getInbox()
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: directinboxpage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        iconName: "\ueaab"

        title: i18n.tr("Welcome to Instagraph Direct!")
        description: i18n.tr("Tap the + icon to send a photo, video or message.")
    }

    Connections{
        target: instagram
        onInboxDataReady: {
            var data = JSON.parse(answer);
            inboxDataFinished(data);
        }
    }
}
