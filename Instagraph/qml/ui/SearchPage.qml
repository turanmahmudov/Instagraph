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
        StyleHints {
            backgroundColor: "#ffffff"
        }
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

            worker.sendMessage({'feed': 'searchPage', 'obj': data.items, 'model': popularFeedModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

            next_coming = false;
        }

        list_loading = false
    }

    function searchUsersDataFinished(data) {
        searchUsersModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.users, 'model': searchUsersModel, 'clear_model': true, 'color': theme.palette.normal.baseText})
    }

    function searchTagsDataFinished(data) {
        searchTagsModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.results, 'model': searchTagsModel, 'clear_model': true, 'color': theme.palette.normal.baseText})
    }

    function searchLocationDataFinished(data) {
        searchPlacesModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.items, 'model': searchPlacesModel, 'clear_model': true, 'color': theme.palette.normal.baseText})
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

    Flickable {
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
        clip: true
        contentWidth: parent.width
        contentHeight: gridChildren.height
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getPopular(next_max_id);
            }
        }

        Grid {
            id: gridChildren
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: popularFeedModel

                GridFeedDelegate {
                    width: (gridView.width-units.gu(0.1))/3
                    height: width
                }
            }
        }

        PullToRefresh {
            parent: gridView
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
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
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
                        width: parent.width - followButton.width

                        CircleImage {
                            width: units.gu(5)
                            height: width
                            source: profile_pic_url
                        }

                        Column {
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: username
                                wrapMode: Text.WordWrap
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: full_name
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                            }
                        }
                    }

                    FollowComponent {
                        id: followButton
                        height: units.gu(3.5)
                        friendship_var: friendship_status
                        userId: pk
                        just_icon: false

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true
                    }
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
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("TagFeedPage.qml"), {tag: name});
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
                        width: parent.width - units.gu(5)

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
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: "#" + name
                                wrapMode: Text.WordWrap
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: media_count + i18n.tr(" posts")
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                            }
                        }
                    }
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
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LocationFeedPage.qml"), {locationId: location.pk, locationName: title});
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
                        width: parent.width - units.gu(5)

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
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: title
                                wrapMode: Text.WordWrap
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: subtitle
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                            }
                        }
                    }
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
