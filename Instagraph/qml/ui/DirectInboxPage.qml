import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: directinboxpage

    property bool list_loading: false

    property bool isEmpty: false

    header: PageHeader {
        title: i18n.tr("Direct")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [newDirectMessageAction]
        }
    }

    function v2InboxDataFinished(data) {
        if (data.inbox.threads.length == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        v2InboxModel.clear()

        for (var i = 0; i < data.inbox.threads.length; i++) {
            data.inbox.threads[i].user_profile_pic_url = typeof data.inbox.threads[i].users[0] != 'undefined' ? data.inbox.threads[i].users[0].profile_pic_url : data.inbox.threads[i].inviter.profile_pic_url;
            data.inbox.threads[i].item_text = data.inbox.threads[i].items[0].text;
            data.inbox.threads[i].item_timestamp = data.inbox.threads[i].items[0].timestamp;
            v2InboxModel.append(data.inbox.threads[i]);
        }

        list_loading = false
    }

    Component.onCompleted: {
        getv2Inbox();
    }

    function getv2Inbox()
    {
        instagram.getv2Inbox();
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: directinboxpage.header.bottom
        visible: instagram.busy || list_loading
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
        }

        clip: true
        cacheBuffer: parent.height*2
        model: v2InboxModel
        delegate: ListItem {
            id: v2InboxDelegate
            divider.visible: false
            height: entry_column.height + units.gu(2)

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
                                source: status == Image.Error ? "../images/not_found_user.jpg" : user_profile_pic_url
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
                        width: typeof image_versions2 != 'undefined' ? parent.width - units.gu(12): parent.width - units.gu(6)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: thread_title != "" ? thread_title : inviter.username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                            textFormat: Text.RichText
                            color: has_newer || last_seen_at[Object.keys(last_seen_at)[0]].timestamp < item_timestamp ? "#275A84" : "#000000"
                        }

                        Text {
                            text: item_text ? item_text : ''
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }

                    Item {
                        visible: typeof image_versions2 != 'undefined'
                        width: typeof image_versions2 != 'undefined' ? units.gu(5) : 0
                        height: width

                        Image {
                            id: feed_image
                            width: parent.width
                            height: width
                            source: typeof image_versions2 != 'undefined' ? image_versions2.candidates[0].url : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(width,height)
                            smooth: true
                            clip: true
                        }

                        Item {
                            width: activity2.width
                            height: width
                            anchors.centerIn: parent
                            opacity: feed_image.status == Image.Loading

                            Behavior on opacity {
                                UbuntuNumberAnimation {
                                    duration: UbuntuAnimation.SlowDuration
                                }
                            }

                            ActivityIndicator {
                                id: activity2
                                running: true
                            }
                        }
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("../ui/DirectThreadPage.qml"), {threadId: thread_id});
            }
        }
        PullToRefresh {
            refreshing: list_loading && v2InboxModel.count == 0
            onRefresh: {
                list_loading = true
                getv2Inbox()
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

        icon: true
        iconName: "mail-unread"

        title: i18n.tr("Welcome to Instagraph Direct!")
        description: i18n.tr("Tap the + icon to send a photo, video or message.")
    }

    Connections{
        target: instagram
        onV2InboxDataReady: {
            var data = JSON.parse(answer);
            v2InboxDataFinished(data);
        }
    }
}
