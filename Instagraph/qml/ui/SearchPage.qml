import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: searchpage

    header: searchHeader

    PageHeader {
        id: searchHeader
        visible: searchpage.header === searchHeader
        title: i18n.tr("Search")
        trailingActionBar {
            numberOfSlots: 1
            actions: [addPeopleAction]
        }
        contents: TextField {
            id: searchInput
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            primaryItem: Icon {
                anchors.leftMargin: units.gu(0.2)
                height: parent.height*0.5
                width: height
                name: "find"
            }
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onAccepted: {
                instagram.searchUsers(text)
                instagram.searchTags(text)
                instagram.searchFBLocation(text)
            }
        }
        extension: Sections {
            visible: searchInput.text != '' || searchInput.activeFocus
            height: searchInput.text != '' || searchInput.activeFocus ? units.gu(5) : 0
            anchors {
                bottom: parent.bottom
            }
            selectedIndex: 0
            actions: [
                Action {
                    text: i18n.tr("People")
                    onTriggered: {
                        current_search_section = 0
                    }
                },
                Action {
                    text: i18n.tr("Tags")
                    onTriggered: {
                        current_search_section = 1
                    }
                },
                Action {
                    text: i18n.tr("Places")
                    onTriggered: {
                        current_search_section = 2
                    }
                }
            ]
        }
    }

    property int current_search_section: 0

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool list_loading: false

    function popularFeedDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available == true ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'searchPage', 'obj': data.items, 'model': popularFeedModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    function searchUsersDataFinished(data) {
        searchUsersModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.users, 'model': searchUsersModel, 'clear_model': true})
    }

    function searchTagsDataFinished(data) {
        searchTagsModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.results, 'model': searchTagsModel, 'clear_model': true})
    }

    function searchLocationDataFinished(data) {
        searchPlacesModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.items, 'model': searchPlacesModel, 'clear_model': true})
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getPopular(next_id)
    {
        clear_models = false
        if (!next_id) {
            popularFeedModel.clear();
            next_max_id = "";
            clear_models = true;
        }
        instagram.getPopularFeed(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: searchpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: popularFeedModel
    }

    ListModel {
        id: searchUsersModel
    }

    ListModel {
        id: searchTagsModel
    }

    ListModel {
        id: searchPlacesModel
    }

    GridView {
        id: gridView
        visible: searchInput.text != '' || searchInput.activeFocus ? false : true
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: searchpage.header.bottom
        }
        width: parent.width
        height: parent.height
        cellWidth: gridView.width/3
        cellHeight: cellWidth
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getPopular(next_max_id);
            }
        }
        model: popularFeedModel
        delegate: ListItem {
            width: parent.width
            height: gridView.cellHeight

            Item {
                width: gridView.cellWidth
                height: gridView.cellHeight

                Image {
                    property var bestImage: typeof image_versions2.candidates != 'undefined' ?
                                                Helper.getBestImage(image_versions2.candidates, parent.width) :
                                                {"width":0, "height":0, "url":""}

                    id: feed_image
                    width: parent.width
                    height: width
                    source: bestImage.url
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width,height)
                    asynchronous: true
                    cache: true
                    smooth: true
                }
                Icon {
                    visible: media_type == 8
                    width: units.gu(3)
                    height: width
                    name: "browser-tabs"
                    color: "#ffffff"
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(1)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(1)
                }
                Icon {
                    visible: media_type == 2
                    width: units.gu(3)
                    height: width
                    name: "camcorder"
                    color: "#ffffff"
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2)
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
                        pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: id});
                    }
                }
            }
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && popularFeedModel.count == 0
            onRefresh: {
                list_loading = true
                getPopular()
            }
        }
    }

    Loader {
        id: viewLoader_search
        visible: searchInput.text != '' || searchInput.activeFocus
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: searchpage.header.bottom
        }
        active: searchUsersList
        sourceComponent: current_search_section == 0 ? searchUsersList : (current_search_section == 1 ? searchTagsList : (current_search_section == 2 ? searchPlacesList : undefined))
    }

    Component {
        id: searchUsersList

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: searchpage.height*2
            model: searchUsersModel
            delegate: ListItem {
                id: searchUsersDelegate
                divider.visible: false
                height: entry_column.height + units.gu(1)

                Column {
                    id: entry_column
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    Item {
                        width: parent.width
                        height: units.gu(0.1)
                    }

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
                                    source: status == Image.Error ? "../images/not_found_user.jpg" : profile_pic_url
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
                            width: parent.width - units.gu(12)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: username
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: full_name
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                width: parent.width
                            }
                        }

                        FollowComponent {
                            width: units.gu(5)
                            height: units.gu(3)
                            friendship_var: friendship_status
                            userId: pk
                        }
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameString: username});
                }
            }
        }
    }

    Component {
        id: searchTagsList

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: searchpage.height*2
            model: searchTagsModel
            delegate: ListItem {
                id: searchTagsDelegate
                divider.visible: false
                height: entry_column.height + units.gu(1)

                Column {
                    id: entry_column
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    Item {
                        width: parent.width
                        height: units.gu(0.1)
                    }

                    Row {
                        spacing: units.gu(1)
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        Item {
                            width: units.gu(5)
                            height: width

                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(3)
                                height: width
                                name: "tag"
                            }
                        }

                        Column {
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "#" + name
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: media_count + i18n.tr(" posts")
                                wrapMode: Text.WordWrap
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TagFeedPage.qml"), {tag: name});
                }
            }
        }
    }

    Component {
        id: searchPlacesList

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: searchpage.height*2
            model: searchPlacesModel
            delegate: ListItem {
                id: searchPlacesDelegate
                divider.visible: false
                height: entry_column.height + units.gu(1)

                Column {
                    id: entry_column
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    Item {
                        width: parent.width
                        height: units.gu(0.1)
                    }

                    Row {
                        spacing: units.gu(1)
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        Item {
                            width: units.gu(5)
                            height: width

                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(3)
                                height: width
                                name: "location"
                            }
                        }

                        Column {
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: title
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: subtitle
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                width: parent.width
                            }
                        }
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LocationFeedPage.qml"), {locationId: location.pk, locationName: title});
                }
            }
        }
    }

    Connections{
        target: instagram
        onPopularFeedDataReady: {
            var data = JSON.parse(answer);
            popularFeedDataFinished(data);
        }
        onSearchUsersDataReady: {
            var data = JSON.parse(answer);
            searchUsersDataFinished(data);
        }
        onSearchTagsDataReady: {
            var data = JSON.parse(answer);
            searchTagsDataFinished(data);
        }
        onSearchFBLocationDataReady: {
            var data = JSON.parse(answer);
            searchLocationDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
