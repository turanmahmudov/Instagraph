// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../viewmodels"
import "../components/Media"
import "../components/Actions"

PageItem {
    id: otheruserpage

    header: PageHeaderItem {
        title: usernameString ? usernameString : ''
        trailingActions: [
            Action {
                id: userMenuAction
                visible: usernameId != activeUsernameId
                text: i18n.tr("Options")
                iconName: IconsConstants.more
                onTriggered: {
                    PopupUtils.open(userMenuComponent);
                }
            },
            Action {
                id: settingsAction
                visible: usernameId == activeUsernameId
                text: i18n.tr("Settings")
                iconName: IconsConstants.settings
                onTriggered: {
                    pageLayout.pushToCurrent(otheruserpage, PagesConstants.options);
                }
            }
        ]
    }

    property var usernameString
    property var usernameId

    property bool selfProfile
    readonly property bool isPrivate: !selfProfile && friendshipViewModel.contentHidden

    FriendshipViewModel {
        id: friendshipViewModel
        userId: usernameId
        onFriendshipLoaded: {
            if (!friendshipViewModel.contentHidden) {
                feedViewModel.loadFeed(true);
            }
        }
    }

    SimilarAccountsViewModel {
        id: similarAccountsViewModel
        userId: usernameId
    }

    // ViewModel handles all feed logic
    UserFeedViewModel {
        id: feedViewModel
        userId: usernameId || ""
        onUserIdResolved: {
            if (!usernameId) {
                usernameId = resolvedUserId;
                loadProfile();
            }
        }
    }

    property int current_user_section: 0

    // Expose loading state and empty state
    property alias list_loading: feedViewModel.isLoading
    property alias isEmpty: feedViewModel.isEmpty
    property alias userData: feedViewModel.userData
    property alias allHighlight: feedViewModel.allHighlight

    property var last_like_id
    property var last_save_id

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
                        friendshipViewModel.block();
                    }
                }
            }

            Connections {
                target: friendshipViewModel
                function onBlocked() {
                    PopupUtils.close(userMenuPopup);
                }
            }
        }
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
        onContentYChanged: {
            if (current_user_section === 3) {
                if (feedViewModel.shouldLoadMoreTags(contentY, contentHeight, height)) {
                    feedViewModel.loadMoreTags();
                }
            } else {
                if (feedViewModel.shouldLoadMore(contentY, contentHeight, height)) {
                    feedViewModel.loadMore();
                }
            }
        }

        Column {
            id: entry_column
            width: parent.width
            y: units.gu(1)

            Loader {
                x: units.gu(1)
                width: parent.width - units.gu(2)
                active: !!userData && userData.hasOwnProperty("username")

                sourceComponent: userDataComponent
            }

            Item {
                width: parent.width
                height: units.gu(2)
            }

            Button {
                id: followingButton
                visible: friendshipViewModel.following
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Following")
                onTriggered: friendshipViewModel.unfollow()
            }

            Button {
                id: unfollowingButton
                visible: friendshipViewModel.canFollow
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: styleApp.common.primaryButtonColor
                text: i18n.tr("Follow")
                onTriggered: friendshipViewModel.follow()
            }

            Button {
                id: requestedButton
                visible: friendshipViewModel.outgoingRequest
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#666666"
                text: i18n.tr("Requested")
                onTriggered: friendshipViewModel.unfollow()
            }

            Button {
                id: unBlockButton
                visible: friendshipViewModel.blocking
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                text: i18n.tr("Unblock")
                onTriggered: friendshipViewModel.unblock()
            }

            Button {
                visible: selfProfile
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: styleApp.common.secondaryButtonColor
                text: i18n.tr("Edit Profile")
                onClicked: {
                    pageLayout.pushToCurrent(otheruserpage, PagesConstants.edit_profile);
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
                height: width / 5 + units.gu(3)
                visible: feedViewModel.highlightsModel.count > 0
            Column {
                visible: similarAccountsViewModel.accountsModel.count > 0
                width: parent.width
                spacing: units.gu(1)

                Label {
                    x: units.gu(1)
                    text: i18n.tr("Suggested for you")
                    font.weight: Font.DemiBold
                }

                SuggestionsSlider {
                    width: parent.width
                    height: contentItem.childrenRect.height
                    model: similarAccountsViewModel.accountsModel
                    currentPage: otheruserpage
                }

                Item {
                    width: parent.width
                    height: units.gu(1)
                }
            }

                active: feedViewModel.highlightsModel.count > 0
                asynchronous: true

                sourceComponent: UserHighlightsTray {
                    currentDelegatePage: otheruserpage
                    model: feedViewModel.highlightsModel
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
                    spacing: (parent.width - units.gu(15)) / 3

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
                                current_user_section = 0;
                                viewLoader.sourceComponent = gridviewComponent;
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
                                current_user_section = 1;
                                viewLoader.sourceComponent = listviewComponent;
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
                                current_user_section = 3;
                                viewLoader.sourceComponent = tagviewComponent;
                                feedViewModel.loadTags(true);
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(LomiriColors.lightGrey, 1.1)
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

                iconName: IconsConstants.image

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? "" : i18n.tr("No photos or videos yet!")
            }

            Rectangle {
                visible: isPrivate ? true : false
                width: isPrivate ? parent.width : 0
                height: isPrivate ? units.gu(0.17) : 0
                color: Qt.lighter(LomiriColors.lightGrey, 1.1)
            }

            EmptyBox {
                visible: isPrivate
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                iconName: IconsConstants.lock

                description: i18n.tr("This account is private.")
                description2: i18n.tr("Follow to see their photos and videos.")
            }
        }
        PullToRefresh {
            parent: flickpage
            refreshing: list_loading && feedViewModel.feedModel.count == 0
            onRefresh: {
                feedViewModel.loadUserInfo();
                feedViewModel.loadFeed(true);
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
            model: feedViewModel.feedModel
            delegate: ListFeedDelegate {
                id: userPhotosDelegate
                currentPage: otheruserpage
                currentModel: feedViewModel.feedModel
            }
        }
    }

    Component {
        id: gridviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: feedViewModel.feedModel

                GridFeedDelegate {
                    currentDelegatePage: otheruserpage
                    width: (viewLoader.width - units.gu(0.1)) / 3
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
                model: feedViewModel.taggedPhotosModel

                GridFeedDelegate {
                    currentDelegatePage: otheruserpage
                    width: (viewLoader.width - units.gu(0.1)) / 3
                    height: width
                }
            }
        }
    }

    // Update header title when user data changes
    Connections {
        target: feedViewModel
        function onUserDataChanged() {
            if (userData) {
                otheruserpage.header.title = userData.username;
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    Component.onCompleted: {
        if (usernameId) {
            loadProfile();
        } else {
            feedViewModel.resolveUsername(usernameString);
        }
    }

    function loadProfile() {
        if (usernameId == activeUsernameId) {
            selfProfile = true;
            feedViewModel.loadFeed(true);
        } else {
            selfProfile = false;
            friendshipViewModel.loadFriendship();
        }

        getUsernameInfo();
    }

    function getUsernameInfo() {
            similarAccountsViewModel.load();
        feedViewModel.loadUserInfo();
    }
}
