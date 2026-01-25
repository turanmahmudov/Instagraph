import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: activitypage

    header: PageHeaderItem {
        title: i18n.tr("Activity")
        noBackAction: true
    }

    property bool new_notifs: false

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool list_loading: false

    property var followRequests
    property bool hasFollowRequests: false

    function recentActivityDataFinished(data) {
        // Follow Requests
        if (typeof data.friend_request_stories != 'undefined' && data.friend_request_stories.length > 0) {
            if (data.friend_request_stories[0].type == '6') {
                hasFollowRequests = true
                followRequests = {"request_count":data.friend_request_stories[0].args.request_count, "profile_pic":data.friend_request_stories[0].args.profile_image}
            } else {
                console.log(data.friend_request_stories)
            }
        } else {
            followRequests = {}
            hasFollowRequests = false
        }

        // Recent Activity
        if (data.new_stories.length) {
            new_notifs = true
        }

        var textColor = Helper.hexToRgb(styleApp.common.textColor)

        worker.sendMessage({'obj': data.new_stories, 'model': recentActivityModel, 'clear_model': true, 'hasFollowRequests': hasFollowRequests, 'textColor': textColor, 'old': false})
        worker.sendMessage({'obj': data.old_stories, 'model': recentActivityModel, 'clear_model': false, 'hasFollowRequests': false, 'textColor': textColor, 'old': true, 'partition': data.partition})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/ActivityWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getRecentActivity()
    {
        recentActivityModel.clear()
        instagram.getRecentActivityInbox();
    }

    ListModel {
        id: recentActivityModel
    }

    Loader {
        id: viewLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: activitypage.header.bottom
        }
        active: true
        sourceComponent: recentActivityComponent
    }

    Component {
        id: recentActivityComponent

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: activitypage.height
            model: recentActivityModel
            delegate: ListItem {
                id: recentActivityDelegate
                height: list_type === 'follow_requests' ? followRequestsActivityHeader.height : recentActivityLoader.height
                divider.visible: false

                Column {
                    id: followRequestsActivityHeader
                    visible: list_type === 'follow_requests'
                    width: list_type === 'follow_requests' ? parent.width : 0

                    Loader {
                        id: followRequestsLoader
                        width: parent.width
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        visible: list_type === 'follow_requests'
                        active: list_type === 'follow_requests'

                        sourceComponent: ListItem {
                            height: layout.height
                            divider.visible: false
                            onClicked: {
                                pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("FollowRequestsPage.qml"));
                            }

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
                                    width: parent.width

                                    CircleImage {
                                        width: units.gu(5)
                                        height: width
                                        source: followRequests.profile_pic
                                    }

                                    Column {
                                        width: parent.width
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            text: i18n.tr("<span style='color:"+LomiriColors.red+";'>%1</span> Follow Requests").arg(followRequests.request_count)
                                            wrapMode: Text.WordWrap
                                            font.weight: Font.DemiBold
                                            textFormat: Text.RichText
                                            width: parent.width
                                        }

                                        Text {
                                            text: i18n.tr("Approve or ignore requests")
                                            wrapMode: Text.WordWrap
                                            font.weight: Font.ExtraLight
                                            width: parent.width
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ListItem {
                        visible: list_type === 'follow_requests'
                        height: list_type === 'follow_requests' ? activityHeaderLayout.height : 0
                        divider.visible: false

                        ListItemLayout {
                            id: activityHeaderLayout

                            title.text: i18n.tr("Activity")
                            title.font.weight: Font.Normal
                        }
                    }
                }

                Loader {
                    id: recentActivityLoader
                    width: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    visible: list_type === 'recent_activity'
                    active: list_type === 'recent_activity'

                    sourceComponent: SlotsLayout {
                        id: layoutRecent
                        anchors.centerIn: parent

                        padding.leading: 0
                        padding.trailing: 0
                        padding.top: units.gu(1)
                        padding.bottom: units.gu(1)

                        mainSlot: Column {
                            width: parent.width

                            Loader {
                                visible: header !== ""
                                active: visible
                                width: parent.width
                                height: units.gu(4)

                                sourceComponent: Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: i18n.tr(header)
                                    width: parent.width
                                    font.weight: Font.DemiBold
                                    color: styleApp.common.textColor
                                }
                            }

                            Row {
                                id: labelRecent
                                spacing: units.gu(1)
                                width: parent.width - (story_type === 3 ? followButton.width : feed_image.width)

                                CircleImage {
                                    width: units.gu(5)
                                    height: width
                                    source: story_type === 13 ? "image://theme/info" : (typeof profile_image !== 'undefined' ? profile_image : "../images/not_found_user.jpg")

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (typeof profile_id !== 'undefined') pageLayout.pushToCurrent(pageLayout.primaryPage, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: profile_id})
                                        }
                                    }
                                }

                                Column {
                                    width: parent.width - units.gu(6)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: (story_type === 3 || story_type === 4) ? Helper.formatRichTextUsers(activity_text) : Helper.formatString(activity_text)
                                        wrapMode: Text.WordWrap
                                        width: parent.width
                                        textFormat: Text.RichText
                                        color: styleApp.common.textColor
                                        font.weight: story_type == 13 ? Font.DemiBold : Font.Normal
                                        onLinkActivated: {
                                            Scripts.linkClick(activitypage, link, story_type === 1 ? media.id : 0)
                                        }
                                    }

                                    Label {
                                        text: Helper.milisecondsToString(timestamp)
                                        fontSize: "small"
                                        color: styleApp.common.text2Color
                                        font.weight: Font.Light
                                        font.capitalization: Font.AllLowercase
                                    }
                                }
                            }
                        }

                        FollowComponent {
                            id: followButton
                            height: units.gu(3.5)
                            visible: story_type == 3 && typeof inline_follow !== 'undefined'
                            friendship_var: inline_follow
                            userId: profile_id

                            anchors.verticalCenter: parent.verticalCenter
                            SlotsLayout.position: SlotsLayout.Trailing
                            SlotsLayout.overrideVerticalPositioning: true
                        }

                        FeedImage {
                            id: feed_image
                            width: (story_type === 1 || story_type === 14) ? units.gu(5) : 0
                            height: width
                            visible: (story_type === 1 || story_type === 14)
                            source: visible ? media.image : ""

                            anchors.verticalCenter: parent.verticalCenter
                            SlotsLayout.position: SlotsLayout.Trailing
                            SlotsLayout.overrideVerticalPositioning: true

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (feed_image.visible) {
                                        pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("SinglePhoto.qml"), {photoId: media.id});
                                    }
                                }
                            }
                        }
                    }
                }
            }
            PullToRefresh {
                id: pullToRefresh
                refreshing: list_loading && recentActivityModel.count == 0
                onRefresh: {
                    list_loading = true
                    getRecentActivity()
                }
            }
        }
    }

    Connections{
        target: instagram
        onRecentActivityInboxDataReady: {
            var data = JSON.parse(answer);
            recentActivityDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
