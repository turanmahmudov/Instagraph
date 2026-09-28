// Qt imports
import QtQuick 2.12
import QtQuick.Layouts 1.12
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
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: userpage

    header: PageHeaderItem {
        title: i18n.tr("User")
        contents: MultiUserSelector {
            id: multiUserSelector
            height: parent.height
            width: parent.width
            onClicked: {
                bottomEdge.commit();
            }
        }
        leadingActions: [
            Action {
                id: addPeopleAction
                text: i18n.tr("Suggestions")
                iconName: IconsConstants.users
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.suggestions);
                }
            }
        ]
        trailingActions: [
            Action {
                id: settingsAction
                text: i18n.tr("Settings")
                iconName: IconsConstants.settings
                onTriggered: {
                    pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.options);
                }
            }
        ]
    }

    // ViewModel handles all feed logic
    UserFeedViewModel {
        id: feedViewModel
        userId: activeUsernameId
    }

    property int current_user_section: 0

    // Expose loading state and empty state
    property alias list_loading: feedViewModel.isLoading
    property alias isEmpty: feedViewModel.isEmpty
    property alias userData: feedViewModel.userData
    property alias allHighlight: feedViewModel.allHighlight

    property var last_like_id
    property var last_save_id

    Flickable {
        id: flickpage
        anchors {
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: userpage.header.bottom
        }
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
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: LomiriColors.green
                text: i18n.tr("Edit Profile")
                onClicked: {
                    pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.edit_profile);
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
                active: feedViewModel.highlightsModel.count > 0

                sourceComponent: UserHighlightsTray {
                    currentDelegatePage: userpage
                    model: feedViewModel.highlightsModel
                    allHighlights: feedViewModel.allHighlight
                    width: parent.width
                    height: parent.height
                }
            }

            Column {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(0.5)
                y: units.gu(2)

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    spacing: (parent.width - units.gu(20)) / 4

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

                    Item {
                        width: units.gu(5)
                        height: width

                        LineIcon {
                            anchors.centerIn: parent
                            name: "\uea39"
                            active: false
                            iconSize: units.gu(2.2)
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.saved_media);
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
                visible: !isEmpty
                width: !isEmpty ? parent.width : 0
                anchors.horizontalCenter: parent.horizontalCenter

                Loader {
                    id: viewLoader
                    asynchronous: true
                    width: parent.width
                    sourceComponent: gridviewComponent
                }
            }

            EmptyBox {
                visible: isEmpty
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                iconName: current_user_section == 3 ? IconsConstants.image : ""

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? i18n.tr("Photos you're tagged in will appear here.") : i18n.tr("Start capturing and sharing your moments")
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

            currentPage: userpage
            currentUserId: activeUsernameId
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
                currentPage: userpage
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
                    currentDelegatePage: userpage
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
                    currentDelegatePage: userpage
                    width: (viewLoader.width - units.gu(0.1)) / 3
                    height: width
                }
            }
        }
    }

    BottomEdge {
        id: bottomEdge
        height: parent.height / 2
        hint.visible: false
        preloadContent: true
        contentComponent: MultipleAccountsSwitcher {
            width: bottomEdge.width
            height: bottomEdge.height
            showAddAccount: true
        }
        onCommitCompleted: {
            bottomEdge.contentItem.init();
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    // Update header title when user data changes
    Connections {
        target: feedViewModel
        function onUserDataChanged() {
            if (userData) {
                userpage.header.title = userData.username;
                activeUserProfilePic = userData.profile_pic_url;
                Storage.updateProfilePic(activeUsername, activeUserProfilePic);
            }
        }
    }

    Component.onCompleted: {
        feedViewModel.loadFeed(true);
    }

    function getUsernameInfo() {
        feedViewModel.loadUserInfo();
    }

    function getUsernameFeed() {
        feedViewModel.loadFeed(true);
    }
}
