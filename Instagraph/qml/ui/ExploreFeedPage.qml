import QtQuick 2.12
import Ubuntu.Components 1.3

import "../components"

PageItem {
    id: exploreFeedPage

    header: PageHeaderItem {
        noBackAction: true
        title: i18n.tr("Search")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: "\uea5a"
                visible: mode != "exploreFeed"
                onTriggered: {
                    if (mode == "searchResults") {
                        searchInput.text = ""
                        mode = "recentSearches"
                    } else if (mode == "recentSearches") {
                        mode = "exploreFeed"
                        searchInput.focus = false
                    }
                }
            }
        ]
        contents: TextField {
            id: searchInput
            anchors {
                left: parent.left
                right: parent.right
                rightMargin: units.gu(1)
                verticalCenter: parent.verticalCenter
            }
            primaryItem: LineIcon {
                anchors.leftMargin: units.gu(0.2)
                iconSize: parent.height*0.4
                active: false
                name: "\ueb7b"
            }
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onActiveFocusChanged: {
                if (searchInput.activeFocus == true && searchInput.text.length == 0) mode = "recentSearches"
            }
            onAccepted: {
                searchKeyword(searchInput.text)
            }
        }
        extension: Sections {
            visible: mode == "searchResults"
            height: visible ? units.gu(5) : 0
            anchors {
                bottom: parent.bottom
            }
            selectedIndex: 0
            actions: [
                Action {
                    text: i18n.tr("Accounts")
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

    property string mode: "exploreFeed" // exploreFeed; recentSearches; searchResults

    property bool firstOpen: true

    property int current_search_section: 0

    Component.onCompleted: {
        instagram.recentSearches()
    }

    function recentSearchesDataFinished(data) {
        recentSearchesModel.clear();

        searchWorker.sendMessage({'type': 'recentSearches', 'obj': data.recent, 'model': recentSearchesModel, 'clear_model': true})
    }

    function searchUsersDataFinished(data) {
        searchUsersModel.clear();

        searchWorker.sendMessage({'type': 'searchUsers', 'obj': data.users, 'model': searchUsersModel, 'clear_model': true})
    }

    function searchTagsDataFinished(data) {
        searchTagsModel.clear();

        searchWorker.sendMessage({'type': 'searchTags', 'obj': data.results, 'model': searchTagsModel, 'clear_model': true})
    }

    function searchLocationDataFinished(data) {
        searchPlacesModel.clear();

        searchWorker.sendMessage({'type': 'searchLocation', 'obj': data.items, 'model': searchPlacesModel, 'clear_model': true})
    }

    function searchKeyword(keyword) {
        mode = "searchResults"

        instagram.searchUser(keyword)
        instagram.searchTags(keyword)
        instagram.searchPlaces(keyword)
    }

    function resetSearch() {
        searchInput.text = ""
    }

    function getExploreFeed(next_id) {

    }

    WorkerScript {
        id: exploreWorker
        source: "../js/ExploreWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    WorkerScript {
        id: searchWorker
        source: "../js/SearchWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    ListModel {
        id: recentSearchesModel
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

    Loader {
        id: exploreFeedLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: exploreFeedPage.header.bottom
        }
        width: parent.width
        height: parent.height
        visible: mode == "exploreFeed"
        active: visible
    }

    Loader {
        id: recentSearchesLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: exploreFeedPage.header.bottom
        }
        width: parent.width
        height: parent.height
        visible: mode == "recentSearches"
        active: visible

        sourceComponent: recentSearches
    }

    Loader {
        id: searchResultsLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: exploreFeedPage.header.bottom
        }
        width: parent.width
        height: parent.height
        visible: mode == "searchResults"
        active: visible

        sourceComponent: current_search_section === 0 ? searchUsersList : (current_search_section === 1 ? searchTagsList : searchPlacesList)
    }

    Component {
        id: recentSearches

        ListView {
            anchors.fill: parent

            clip: true
            cacheBuffer: exploreFeedPage.height
            model: recentSearchesModel
            delegate: ListItem {
                width: parent.width
                height: search_type == "user" ? userLoader.childrenRect.height : keywordLoader.childrenRect.height
                divider.visible: false
                onClicked: {
                    if (search_type == "user") {
                        pageLayout.pushToCurrent(exploreFeedPage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
                    } else {
                        searchInput.text = name
                        searchKeyword(name)
                    }
                }

                Loader {
                    id: userLoader
                    width: parent.width
                    visible: search_type == "user"
                    active: visible
                    sourceComponent: SlotsLayout {
                        anchors.centerIn: parent

                        padding.leading: 0
                        padding.trailing: 0
                        padding.top: units.gu(1)
                        padding.bottom: units.gu(1)

                        mainSlot: UserRowSlot {
                            width: parent.width
                        }
                    }
                }

                Loader {
                    id: keywordLoader
                    width: parent.width
                    visible: search_type == "keyword"
                    active: visible
                    sourceComponent: SlotsLayout {
                        anchors.centerIn: parent

                        padding.leading: 0
                        padding.trailing: 0
                        padding.top: units.gu(1)
                        padding.bottom: units.gu(1)

                        mainSlot: Row {
                            width: parent.width
                            spacing: units.gu(1)

                            Item {
                                width: units.gu(5)
                                height: width

                                LineIcon {
                                    anchors.centerIn: parent
                                    name: "\ueb7b"
                                }
                            }

                            Column {
                                width: parent.width
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    text: name
                                    wrapMode: Text.WordWrap
                                    font.weight: Font.DemiBold
                                    width: parent.width
                                    color: styleApp.common.textColor
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: searchUsersList

        ListView {
            anchors.fill: parent

            clip: true
            cacheBuffer: exploreFeedPage.height
            model: searchUsersModel
            delegate: ListItem {
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageLayout.pushToCurrent(exploreFeedPage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
                }

                SlotsLayout {
                    id: layout
                    anchors.centerIn: parent

                    padding.leading: 0
                    padding.trailing: 0
                    padding.top: units.gu(1)
                    padding.bottom: units.gu(1)

                    mainSlot: UserRowSlot {
                        id: label
                        width: parent.width
                    }
                }
            }
        }
    }

    Component {
        id: searchTagsList

        ListView {
            anchors.fill: parent

            clip: true
            cacheBuffer: exploreFeedPage.height
            model: searchTagsModel
            delegate: ListItem {
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageLayout.pushToCurrent(exploreFeedPage, Qt.resolvedUrl("TagFeedPage.qml"), {tag: name});
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

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                                radius: width/2

                                LineIcon {
                                    anchors.centerIn: parent
                                    width: units.gu(3)
                                    height: width
                                    name: "\uebb5"
                                }
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
                                color: styleApp.common.textColor
                            }

                            Text {
                                text: media_count + i18n.tr(" posts")
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                color: styleApp.common.textColor
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
            anchors.fill: parent

            clip: true
            cacheBuffer: exploreFeedPage.height
            model: searchPlacesModel
            delegate: ListItem {
                height: layout.height
                divider.visible: false
                onClicked: {
                    pageLayout.pushToCurrent(exploreFeedPage, Qt.resolvedUrl("LocationFeedPage.qml"), {locationId: pk, locationName: title});
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

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                                radius: width/2

                                LineIcon {
                                    anchors.centerIn: parent
                                    width: units.gu(3)
                                    height: width
                                    name: "\ueb1c"
                                }
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
                                color: styleApp.common.textColor
                            }

                            Text {
                                text: subtitle
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                color: styleApp.common.textColor
                            }
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onRecentSearchesDataReady: {
            var data = JSON.parse(answer);
            recentSearchesDataFinished(data);
        }
        onSearchUserDataReady: {
            var data = JSON.parse(answer);
            searchUsersDataFinished(data);
        }
        onSearchTagsDataReady: {
            var data = JSON.parse(answer);
            searchTagsDataFinished(data);
        }
        onSearchPlacesDataReady: {
            var data = JSON.parse(answer);
            searchLocationDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
