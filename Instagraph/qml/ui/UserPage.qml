import QtQuick 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Components.Popups 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: userpage

    header: PageHeaderItem {
        title: i18n.tr("User")
        contents: MultiUserSelector {
            id: multiUserSelector
            height: parent.height
            width: parent.width
            onClicked: {
                bottomEdge.commit()
            }
        }
        leadingActions: [
            Action {
                id: addPeopleAction
                text: i18n.tr("Suggestions")
                iconName: "\uebdf"
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("SuggestionsPage.qml"));
                }
            }
        ]
        trailingActions: [
            Action {
                id: settingsAction
                text: i18n.tr("Settings")
                iconName: "\uea6f"
                onTriggered: {
                    pageLayout.pushToCurrent(pageLayout.primaryPage, Qt.resolvedUrl("OptionsPage.qml"));
                }
            }
        ]
    }

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

        userPage.header.title = userData.username

        activeUserProfilePic = userData.profile_pic_url
        Storage.updateProfilePic(activeUsername, activeUserProfilePic)

        getUserHighlightFeed()
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
            next_max_id = data.more_available == true ? data.next_max_id : "";
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
        instagram.getInfoById(activeUsernameId);
    }

    function getUsernameFeed(next_id)
    {
        clear_models = false
        if (!next_id) {
            userPhotosModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getUserFeed(activeUsernameId, next_id);
    }

    function getUserHighlightFeed()
    {
        userHighlightsModel.clear()
        instagram.getUserHighlightFeed(activeUsernameId);
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
            top: userpage.header.bottom
        }
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
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                color: UbuntuColors.green
                text: i18n.tr("Edit Profile")
                onClicked: {
                    pageLayout.pushToCurrent(pageLayout.primaryPage, Qt.resolvedUrl("EditProfilePage.qml"));
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
                    currentDelegatePage: userpage
                    model: userHighlightsModel
                    allHighlights: allHighlight
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
                    spacing: (parent.width-units.gu(20))/4

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
                                instagram.getUserTags(activeUsernameId)
                                current_user_section = 3
                                viewLoader.sourceComponent = tagviewComponent
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
                                pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("SavedMediaPage.qml"))
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

                iconName: current_user_section == 3 ? "\ueaeb" : ""

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? i18n.tr("Photos you're tagged in will appear here.") : i18n.tr("Start capturing and sharing your moments")
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
            model: userPhotosModel
            delegate: ListFeedDelegate {
                id: userPhotosDelegate
                currentDelegatePage: userpage
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
                    currentDelegatePage: userpage
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
                    currentDelegatePage: userpage
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width
                }
            }
        }
    }

    BottomEdge {
        id: bottomEdge
        height: parent.height/2
        hint.visible: false
        preloadContent: true
        contentComponent: MultipleAccountsSwitcher {
            width: bottomEdge.width
            height: bottomEdge.height
            showAddAccount: true
        }
        onCommitCompleted: {
            bottomEdge.contentItem.init()
        }
    }

    Connections{
        target: instagram
        onUserFeedDataReady: {
            var data = JSON.parse(answer);
            if (data.status === "ok") {
                userTimeLineDataFinished(data);
            } else {
                // error
            }
        }
        onInfoByIdDataReady: {
            var data = JSON.parse(answer);
            if (data.user.pk == activeUsernameId) {
                usernameDataFinished(data);
            }
        }
        onUserTagsDataReady: {
            var data = JSON.parse(answer);
            userTagDataFinished(data);
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
