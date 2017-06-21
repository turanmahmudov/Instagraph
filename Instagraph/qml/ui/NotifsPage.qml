import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: notifspage

    header: PageHeader {
        title: i18n.tr("Activity")
        extension: Sections {
            anchors {
                bottom: parent.bottom
            }
            selectedIndex: 1
            actions: [
                Action {
                    text: i18n.tr("Following")
                    onTriggered: {
                        current_notifs_section = 0
                        if (followingRecentActivityModel.count == 0) {
                            getFollowingRecentActivity();
                        }
                    }
                },
                Action {
                    text: i18n.tr("You")
                    onTriggered: {
                        current_notifs_section = 1
                    }
                }
            ]
        }
    }

    property int current_notifs_section: 1

    property bool list_loading: false
    property bool list_loading_following: false

    property bool isEmptyFollowing: false

    function recentActivityDataFinished(data) {
        if (data.new_stories.length) {
            new_notifs = true
        }

        worker.sendMessage({'obj': data.new_stories, 'model': recentActivityModel, 'clear_model': true})
        worker.sendMessage({'obj': data.old_stories, 'model': recentActivityModel, 'clear_model': false})

        list_loading = false
    }

    function followingRecentActivityDataFinished(data) {
        if (data.stories.length == 0) {
            isEmptyFollowing = true;
        } else {
            isEmptyFollowing = false;
        }

        worker.sendMessage({'obj': data.stories, 'model': followingRecentActivityModel, 'clear_model': true})

        list_loading_following = false
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
        instagram.getRecentActivity();
    }

    function getFollowingRecentActivity()
    {
        followingRecentActivityModel.clear()
        instagram.getFollowingRecentActivity();
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: notifspage.header.bottom
        visible: instagram.busy || list_loading || list_loading_following
    }

    ListModel {
        id: recentActivityModel
    }

    ListModel {
        id: followingRecentActivityModel
    }

    Loader {
        id: viewLoader
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: notifspage.header.bottom
        }
        active: recentActivityComponent
        sourceComponent: current_notifs_section == 0 ? (isEmptyFollowing ? emptyFollowingRecentActivityComponent : followingRecentActivityComponent) : (current_notifs_section == 1 ? recentActivityComponent : undefined)
    }

    Component {
        id: recentActivityComponent

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: notifspage.height*2
            model: recentActivityModel
            delegate: ListItem {
                id: recentActivityDelegate
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
                                    source: story.type == 13 ? "image://theme/info" : (status == Image.Error ? "../images/not_found_user.jpg" : story.args.profile_image)
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

                            MouseArea {
                                anchors {
                                    fill: parent
                                }
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: story.args.profile_id});
                                }
                            }
                        }

                        Column {
                            width: story.type == 4 ? parent.width - units.gu(6): parent.width - units.gu(12)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: Helper.formatString(activity_text)
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                font.weight: story.type == 13 ? Font.DemiBold : Font.Normal
                                onLinkActivated: {
                                    Scripts.linkClick(link, story.type == 1 ? story.args.media[0].id : 0)
                                }
                            }

                            Text {
                                text: Helper.milisecondsToString(story.args.timestamp)
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                font.capitalization: Font.AllLowercase
                            }
                        }

                        Item {
                            visible: story.type == 1
                            width: story.type == 1 ? units.gu(5) : 0
                            height: width

                            Image {
                                id: feed_image
                                width: parent.width
                                height: width
                                source: story.type == 1 ? story.args.media[0].image : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                asynchronous: true
                                cache: true
                                smooth: false
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

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (story.type == 1) {
                                        pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: story.args.media[0].id});
                                    }
                                }
                            }
                        }

                        FollowComponent {
                            visible: story.type == 3
                            width: story.type == 3 ? units.gu(5) : 0
                            height: units.gu(3)
                            friendship_var: story.args.inline_follow
                            userId: story.args.profile_id
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

    Component {
        id: followingRecentActivityComponent

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: notifspage.height*2
            model: followingRecentActivityModel
            delegate: ListItem {
                id: followingRecentActivityDelegate
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
                                    source: status == Image.Error ? "../images/not_found_user.jpg" : story.args.profile_image
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

                            MouseArea {
                                anchors {
                                    fill: parent
                                }
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: story.args.profile_id});
                                }
                            }
                        }

                        Column {
                            width: story.type == 2 || story.type == 4 ? parent.width - units.gu(6): parent.width - units.gu(12)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: Helper.formatString(activity_text)
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                onLinkActivated: {
                                    Scripts.linkClick(link, story.type == 1 ? story.args.media[0].id : 0)
                                }
                            }

                            Text {
                                text: Helper.milisecondsToString(story.args.timestamp)
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                font.capitalization: Font.AllLowercase
                            }
                        }

                        Item {
                            visible: story.type == 1
                            width: story.type == 1 ? units.gu(5) : 0
                            height: width

                            Image {
                                id: feed_image
                                width: parent.width
                                height: width
                                source: story.type == 1 ? story.args.media[0].image : ""
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                asynchronous: true
                                cache: true
                                smooth: false
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

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (story.type == 1) {
                                        pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: story.args.media[0].id});
                                    }
                                }
                            }
                        }
                    }

                    Grid {
                        visible: story.type == 2
                        anchors.left: parent.left
                        anchors.leftMargin: units.gu(6)
                        width: parent.width - units.gu(6)
                        columns: 6
                        spacing: units.gu(0.2)

                        Repeater {
                            model: Helper.objectLength(story.args.media) > 1 ? Helper.objectLength(story.args.media) : 0

                            Rectangle {
                                width: parent.width/7
                                height: width

                                Image {
                                    width: parent.width
                                    height: width
                                    source: story.args.media[index].image
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize: Qt.size(width,height)
                                    asynchronous: true
                                    cache: true
                                    smooth: false
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        if (story.type == 2) {
                                            pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: story.args.media[index].id});
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            PullToRefresh {
                id: pullToRefresh
                refreshing: list_loading_following && followingRecentActivityModel.count == 0
                onRefresh: {
                    list_loading_following = true
                    getFollowingRecentActivity()
                }
            }
        }
    }

    Component {
        id: emptyFollowingRecentActivityComponent

        EmptyBox {
            anchors.fill: parent

            icon: true
            iconName: "unlike"

            title: i18n.tr("Activity from people you follow")
            description: i18n.tr("When someone you follow comments on or likes a post, you'll see it here.")
        }
    }

    Connections{
        target: instagram
        onRecentActivityDataReady: {
            var data = JSON.parse(answer);
            recentActivityDataFinished(data);
        }
        onFollowingRecentDataReady: {
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                followingRecentActivityDataFinished(data);
            } else {
                // error
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
