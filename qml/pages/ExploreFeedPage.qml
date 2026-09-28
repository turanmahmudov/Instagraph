// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/Explore"
import "../viewmodels"

PageItem {
    id: exploreFeedPage

    header: PageHeaderItem {
        noBackAction: true
        title: i18n.tr("Search")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: IconsConstants.flash_on
                visible: mode != "exploreFeed"
                onTriggered: {
                    if (mode == "searchResults") {
                        searchInput.text = "";
                        mode = "recentSearches";
                    } else if (mode == "recentSearches") {
                        mode = "exploreFeed";
                        searchInput.focus = false;
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
                iconSize: parent.height * 0.4
                active: false
                name: ""
            }
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onActiveFocusChanged: {
                if (searchInput.activeFocus == true && searchInput.text.length == 0)
                    mode = "recentSearches";
            }
            onAccepted: {
                searchKeyword(searchInput.text);
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
                        current_search_section = 0;
                    }
                },
                Action {
                    text: i18n.tr("Tags")
                    onTriggered: {
                        current_search_section = 1;
                    }
                },
                Action {
                    text: i18n.tr("Places")
                    onTriggered: {
                        current_search_section = 2;
                    }
                }
            ]
        }
    }

    property string mode: "exploreFeed" // exploreFeed; recentSearches; searchResults

    property bool firstOpen: true

    property int current_search_section: 0

    ExploreViewModel {
        id: exploreViewModel
    }

    property alias list_loading: exploreViewModel.isLoading

    Component.onCompleted: {
        exploreViewModel.loadRecentSearches();
    }

    function searchKeyword(keyword) {
        mode = "searchResults";

        exploreViewModel.search(keyword);
    }

    function resetSearch() {
        searchInput.text = "";
    }

    function getExploreFeed() {
        exploreViewModel.loadFeed(true);
    }

    Loader {
        id: exploreLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: exploreFeedPage.header.bottom
        }

        sourceComponent: getSourceComponent()

        function getSourceComponent() {
            if (mode === "recentSearches")
                return recentSearches;
            if (mode === "searchResults") {
                if (current_search_section === 1)
                    return searchTagsList;
                if (current_search_section === 2)
                    return searchPlacesList;
                return searchUsersList;
            }
            return exploreFeed;
        }
    }

    Component {
        id: exploreFeed

        ExploreFeedList {
            anchors.fill: parent
            currentPage: exploreFeedPage
            model: exploreViewModel.feedModel
            refreshing: list_loading && exploreViewModel.feedModel.count == 0
            onMovementEnded: {
                if (atYEnd) {
                    exploreViewModel.loadMore();
                }
            }
            onRefreshRequested: exploreViewModel.loadFeed(true)
        }
    }

    Component {
        id: recentSearches

        RecentSearchesList {
            anchors.fill: parent
            cacheBuffer: exploreFeedPage.height
            currentPage: exploreFeedPage
            model: exploreViewModel.recentSearchesModel
            onKeywordClicked: {
                searchInput.text = name;
                searchKeyword(name);
            }
        }
    }

    Component {
        id: searchUsersList

        SearchUsersList {
            anchors.fill: parent
            cacheBuffer: exploreFeedPage.height
            currentPage: exploreFeedPage
            model: exploreViewModel.searchUsersModel
        }
    }

    Component {
        id: searchTagsList

        SearchTagsList {
            anchors.fill: parent
            cacheBuffer: exploreFeedPage.height
            currentPage: exploreFeedPage
            model: exploreViewModel.searchTagsModel
        }
    }

    Component {
        id: searchPlacesList

        SearchPlacesList {
            anchors.fill: parent
            cacheBuffer: exploreFeedPage.height
            currentPage: exploreFeedPage
            model: exploreViewModel.searchPlacesModel
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
