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

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property int current_notifs_section: 1

    property bool list_loading: false
    property bool list_loading_following: false

    property bool isEmptyFollowing: false

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

        worker.sendMessage({'obj': data.new_stories, 'model': recentActivityModel, 'clear_model': true, 'hasFollowRequests': hasFollowRequests})
        worker.sendMessage({'obj': data.old_stories, 'model': recentActivityModel, 'clear_model': false, 'hasFollowRequests': false})

        list_loading = false
    }

    function followingRecentActivityDataFinished(data) {
        if (data.stories.length == 0) {
            isEmptyFollowing = true;
        } else {
            isEmptyFollowing = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.auto_load_more_enabled == true ? data.next_max_id : "";
            more_available = data.auto_load_more_enabled;
            next_coming = true;

            worker.sendMessage({'obj': data.stories, 'model': followingRecentActivityModel, 'clear_model': clear_models})

            next_coming = false;
        }

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

    function getFollowingRecentActivity(next_id)
    {
        clear_models = false
        if (!next_id) {
            followingRecentActivityModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getFollowingRecentActivity(next_id);
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
            right: parent.right
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
                                pageStack.push(Qt.resolvedUrl("FollowRequestsPage.qml"));
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
                                            text: i18n.tr("<span style='color:"+UbuntuColors.red+";'>%1</span> Follow Requests").arg(followRequests.request_count)
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
                        id: layout
                        anchors.centerIn: parent

                        padding.leading: 0
                        padding.trailing: 0
                        padding.top: units.gu(1)
                        padding.bottom: units.gu(1)

                        mainSlot: Row {
                            id: label
                            spacing: units.gu(1)
                            width: parent.width - (story.type == 3 ? followButton.width : feed_image.width)

                            CircleImage {
                                width: units.gu(5)
                                height: width
                                source: story.type == 13 ? "image://theme/info" : (typeof story.args.profile_image !== 'undefined' ? story.args.profile_image : "../images/not_found_user.jpg")

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: story.args.profile_id});
                                    }
                                }
                            }

                            Column {
                                width: parent.width - units.gu(6)
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

                                Label {
                                    text: Helper.milisecondsToString(story.args.timestamp)
                                    fontSize: "small"
                                    color: UbuntuColors.darkGrey
                                    font.weight: Font.Light
                                    font.capitalization: Font.AllLowercase
                                }
                            }
                        }

                        FollowComponent {
                            id: followButton
                            height: units.gu(3.5)
                            visible: story.type == 3
                            friendship_var: story.args.inline_follow
                            userId: story.args.profile_id
                            just_icon: isPhone ? true : false

                            anchors.verticalCenter: parent.verticalCenter
                            SlotsLayout.position: SlotsLayout.Trailing
                            SlotsLayout.overrideVerticalPositioning: true
                        }

                        FeedImage {
                            id: feed_image
                            width: (story.type == 1 || story.type == 14) ? units.gu(5) : 0
                            height: width
                            visible: (story.type == 1 || story.type == 14)
                            source: (story.type == 1 || story.type == 14) ? story.args.media[0].image : ""

                            anchors.verticalCenter: parent.verticalCenter
                            SlotsLayout.position: SlotsLayout.Trailing
                            SlotsLayout.overrideVerticalPositioning: true

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    if (story.type == 1 || story.type == 14) {
                                        pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: story.args.media[0].id});
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

    Component {
        id: followingRecentActivityComponent

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: notifspage.height*2
            model: followingRecentActivityModel
            onMovementEnded: {
                if (atYEnd && more_available && !next_coming) {
                    getFollowingRecentActivity(next_max_id)
                }
            }
            delegate: ListItem {
                id: followingRecentActivityDelegate
                height: layout.height
                divider.visible: false

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
                        width: parent.width - (story.type == 1 ? feed_image.width : 0)

                        CircleImage {
                            width: units.gu(5)
                            height: width
                            source: typeof story.args.profile_image !== 'undefined' ? story.args.profile_image : "../images/not_found_user.jpg"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: story.args.profile_id});
                                }
                            }
                        }

                        Column {
                            width: parent.width - units.gu(6)
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

                            Label {
                                text: Helper.milisecondsToString(story.args.timestamp)
                                fontSize: "small"
                                color: UbuntuColors.darkGrey
                                font.weight: Font.Light
                                font.capitalization: Font.AllLowercase
                            }

                            Item {
                                width: parent.width
                                height: units.gu(1)
                            }

                            Grid {
                                visible: story.type == 2
                                width: parent.width
                                columns: 6
                                spacing: units.gu(0.2)

                                Repeater {
                                    model: Helper.objectLength(story.args.media) > 1 ? Helper.objectLength(story.args.media) : 0

                                    Rectangle {
                                        width: parent.width/7
                                        height: width

                                        FeedImage {
                                            width: parent.width
                                            height: width
                                            source: story.args.media[index].image
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

                    FeedImage {
                        id: feed_image
                        width: (story.type == 1 || story.type == 14) ? units.gu(5) : 0
                        height: width
                        visible: (story.type == 1 || story.type == 14)
                        source: (story.type == 1 || story.type == 14) ? story.args.media[0].image : ""

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (story.type == 1 || story.type == 14) {
                                    pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: story.args.media[0].id});
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
