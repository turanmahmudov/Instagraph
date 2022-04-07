import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Components.Popups 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: otheruserpage

    header: PageHeaderItem {
        title: usernameString ? usernameString : ''
        trailingActions: [
            Action {
                visible: usernameId !== activeUsernameId
                id: userMenuAction
                text: i18n.tr("Options")
                iconName: "\ueb2e"
                onTriggered: {
                    PopupUtils.open(userMenuComponent)
                }
            },
            Action {
                visible: usernameId === activeUsernameId
                id: settingsAction
                text: i18n.tr("Settings")
                iconName: "\uea6f"
                onTriggered: {
                    pageLayout.pushToCurrent(otheruserpage, Qt.resolvedUrl("OptionsPage.qml"));
                }
            }
        ]
    }

    property var usernameString
    property var usernameId

    property var latest_follow_request

    property bool selfProfile
    property bool isPrivate: false

    property var next_max_id
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property var last_save_id
    property bool clear_models: true

    property int current_user_section: 0

    property bool list_loading: false

    property bool isEmpty: false

    property var allHighlight: []

    property var userData

    function usernameDataFinished(data) {
        userData = data.user

        otheruserpage.header.title = data.user.username;

        getUserHighlightFeed();
    }

    function highlightFeedDataFinished(data) {
        highlightsWorker.sendMessage({'feed': 'UserHighlights', 'obj': data.tray, 'model': userHighlightsModel, 'clear_model': true})

        for (var i = 0; i < data.tray.length; i++) {
            allHighlight.push(data.tray[i].id)
        }
    }

    function userTimeLineDataFinished(data) {
        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id;
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'userPage', 'obj': data.items, 'model': userPhotosModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    function userTagDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id;
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'userPage', 'obj': data.items, 'model': userTagPhotosModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    function followDataFinished(data) {
        if (usernameId == latest_follow_request) {
            if (data.friendship_status) {
                followingButton.visible = data.friendship_status.following
                unfollowingButton.visible = !data.friendship_status.following && !data.friendship_status.outgoing_request && !data.friendship_status.blocking
                requestedButton.visible = data.friendship_status.outgoing_request
                unBlockButton.visible = data.friendship_status.blocking

                latest_follow_request = 0
            }
        }
    }

    Component.onCompleted: {
        if (usernameId) {
            if (usernameId == activeUsernameId) {
                selfProfile = true

                getUsernameFeed();
            } else {
                selfProfile = false

                instagram.getFriendship(usernameId);
            }

            getUsernameInfo()
        } else {
            instagram.getInfoByName(usernameString)
        }
    }

    WorkerScript {
        id: worker
        source: "../js/TimelineWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    WorkerScript {
        id: highlightsWorker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getUsernameInfo()
    {
        instagram.getInfoById(usernameId);
    }

    function getUsernameFeed(next_id)
    {
        clear_models = false
        if (!next_id) {
            userPhotosModel.clear();
            next_max_id = 0
            clear_models = true
        }
        instagram.getUserFeed(usernameId, next_id);
    }

    function getUserHighlightFeed()
    {
        userHighlightsModel.clear()
        instagram.getUserHighlightFeed(usernameId);
    }

    Component {
        id: userMenuComponent
        ActionSelectionPopover {
            id: userMenuPopup
            target: otheruserpage.header
            delegate: ListItem {
                height: entry_column.height + units.gu(4)

                Column {
                    id: entry_column
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1)
                    width: parent.width - units.gu(4)
                    y: units.gu(2)

                    Label {
                        text: action.text
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                    }
                }
            }
            actions: ActionList {
                  Action {
                      text: i18n.tr("Block")
                      onTriggered: {
                            instagram.block(usernameId)
                      }
                  }
            }

            Connections {
                target: instagram
                onBlockDataReady: {
                    var data = JSON.parse(answer);

                    if (data.friendship_status.blocking) {
                        followingButton.visible = false
                        unfollowingButton.visible = false
                        requestedButton.visible = false
                        unBlockButton.visible = true

                        PopupUtils.close(userMenuPopup)
                    }
                }
            }
        }
    }

    ListModel {
        id: userPhotosModel
    }

    ListModel {
        id: userTagPhotosModel
    }

    ListModel {
        id: userHighlightsModel
    }

    Flickable {
        id: flickpage
        anchors {
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: otheruserpage.header.bottom
        }
        clip: true
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: entry_column.height
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getUsernameFeed(next_max_id);
            }
        }

        Column {
            id: entry_column
            width: parent.width
            y: units.gu(1)

            Loader {
                x: units.gu(1)
                width: parent.width - units.gu(2)
                active: typeof userData != 'undefined' && userData.hasOwnProperty("username")

                sourceComponent: userDataComponent
            }

            Item {
                width: parent.width
                height: units.gu(2)
            }

            Button {
                id: followingButton
                visible: false
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Following")
                onTriggered: {
                    latest_follow_request = usernameId
                    instagram.unFollow(usernameId)
                }
            }

            Button {
                id: unfollowingButton
                visible: false
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: UbuntuColors.green
                text: i18n.tr("Follow")
                onTriggered: {
                    latest_follow_request = usernameId
                    instagram.follow(usernameId)
                }
            }

            Button {
                id: requestedButton
                visible: false
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#666666"
                text: i18n.tr("Requested")
                onTriggered: {
                    latest_follow_request = usernameId
                    instagram.unFollow(usernameId)
                }
            }

            Button {
                id: unBlockButton
                visible: false
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Unblock")
                onTriggered: {
                    latest_follow_request = usernameId
                    instagram.unBlock(usernameId)
                }
            }

            Button {
                visible: selfProfile
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: UbuntuColors.green
                text: i18n.tr("Edit Profile")
                onClicked: {
                    pageLayout.pushToCurrent(otheruserpage, Qt.resolvedUrl("EditProfilePage.qml"));
                }
            }

            Item {
                width: parent.width
                height: units.gu(2)
            }

            Loader {
                id: storiesFeedTrayLoader
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - units.gu(2)
                height: width/5 + units.gu(3)
                visible: userHighlightsModel.count > 0
                active: userHighlightsModel.count > 0
                asynchronous: true

                sourceComponent: UserHighlightsTray {
                    currentDelegatePage: otheruserpage
                    model: userHighlightsModel
                    allHighlights: allHighlight
                    width: parent.width
                    height: parent.height
                }
            }

            Column {
                visible: !isPrivate
                width: !isPrivate ? parent.width : 0
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(0.5)
                y: !isPrivate ? units.gu(2) : 0

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    spacing: (parent.width-units.gu(15))/3

                    Item {
                        width: units.gu(5)
                        height: width

                        LineIcon {
                            anchors.centerIn: parent
                            name: "\uead5"
                            active: current_user_section == 0
                            iconSize: units.gu(2.2)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                current_user_section = 0
                                viewLoader.sourceComponent = gridviewComponent
                            }
                        }
                    }

                    Item {
                        width: units.gu(5)
                        height: width

                        LineIcon {
                            anchors.centerIn: parent
                            name: "\ueb16"
                            active: current_user_section == 1
                            iconSize: units.gu(2.2)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                current_user_section = 1
                                viewLoader.sourceComponent = listviewComponent
                            }
                        }
                    }

                    Item {
                        width: units.gu(5)
                        height: width

                        LineIcon {
                            anchors.centerIn: parent
                            name: "\uebde"
                            active: current_user_section == 3
                            iconSize: units.gu(2.2)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next_max_id = 0
                                instagram.getUserTags(usernameId)
                                current_user_section = 3
                                viewLoader.sourceComponent = tagviewComponent
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                }
            }

            Column {
                visible: !isPrivate && !isEmpty
                width: !isPrivate && !isEmpty ? parent.width : 0
                anchors.horizontalCenter: parent.horizontalCenter

                Loader {
                    id: viewLoader
                    width: flickpage.width
                    sourceComponent: gridviewComponent
                }
            }

            EmptyBox {
                visible: isEmpty
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                iconName: "\ueaeb"

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? "" : i18n.tr("No photos or videos yet!")
            }

            Rectangle {
                visible: isPrivate ? true : false
                width: isPrivate ? parent.width : 0
                height: isPrivate ? units.gu(0.17) : 0
                color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
            }

            EmptyBox {
                visible: isPrivate
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                iconName: "\ueb17"

                description: i18n.tr("This account is private.")
                description2: i18n.tr("Follow to see their photos and videos.")
            }
        }
        PullToRefresh {
            parent: flickpage
            refreshing: list_loading && userPhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getUsernameInfo()
                getUsernameFeed()
            }
        }
    }

    Component {
        id: userDataComponent

        UserDataColumn {
            width: parent.width

            currentPage: otheruserpage
            currentUserId: usernameId
        }
    }

    Component {
        id: listviewComponent

        ListView {
            width: viewLoader.width
            height: contentHeight
            interactive: false
            model: userPhotosModel
            delegate: ListFeedDelegate {
                id: userPhotosDelegate
                currentDelegatePage: otheruserpage
                thismodel: userPhotosModel
            }
        }
    }

    Component {
        id: gridviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: userPhotosModel

                GridFeedDelegate {
                    currentDelegatePage: otheruserpage
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width
                }
            }
        }
    }

    Component {
        id: tagviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: userTagPhotosModel

                GridFeedDelegate {
                    currentDelegatePage: otheruserpage
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width
                }
            }
        }
    }

    Connections{
        target: instagram
        onUserFeedDataReady: {
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                userTimeLineDataFinished(data);
            } else {
                // error
            }
        }
        onInfoByIdDataReady: {
            var data = JSON.parse(answer);
            usernameDataFinished(data);
        }
        onInfoByNameDataReady: {
            var data = JSON.parse(answer);
            usernameId = data.user.pk;

            if (usernameId === activeUsernameId) {
                selfProfile = true

                getUsernameFeed();
            } else {
                selfProfile = false

                instagram.getFriendship(usernameId);
            }

            getUsernameInfo();
        }
        onFriendshipDataReady: {
            var data = JSON.parse(answer);

            if (!data.following && data.is_private) {
                isPrivate = true
            } else {
                isPrivate = false

                getUsernameFeed();
            }

            followingButton.visible = data.following
            unfollowingButton.visible = !data.following && !data.outgoing_request && !data.blocking
            requestedButton.visible = data.outgoing_request
            unBlockButton.visible = data.blocking
        }
        onUserTagsDataReady: {
            var data = JSON.parse(answer);
            userTagDataFinished(data);
        }

        onFollowDataReady: {
            if (usernameId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
        onUnfollowDataReady: {
            if (usernameId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
        onUnBlockDataReady: {
            var data = JSON.parse(answer);

            if (data.status == "ok" && !data.friendship_status.blocking) {
                followingButton.visible = false
                unfollowingButton.visible = true
                requestedButton.visible = false
                unBlockButton.visible = false
            }
        }
        onUserHighlightFeedDataReady: {
            var data = JSON.parse(answer)
            highlightFeedDataFinished(data)
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
