// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

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
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: suggestionspage

    header: PageHeaderItem {
        title: i18n.tr("Suggestions")
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    property bool list_loading: false

    function suggestionsDataFinished(data) {
        more_available = data.more_available
        next_coming = true

        for (var i = 0; i < data.suggested_users.suggestions.length; i++) {

            suggestionsModel.append(data.suggested_users.suggestions[i].user);
        }

        next_coming = false;

        list_loading = false
    }

    Component.onCompleted: {
        suggestions();
    }

    function suggestions()
    {
        suggestionsModel.clear()
        list_loading = true
        instagram.getSuggestions();
    }

    ListModel {
        id: suggestionsModel
    }

    UsersListView {
        id: suggestionsList
        model: suggestionsModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(suggestionspage, PagesConstants.user, {usernameId: pk})
            followButton: true
            followData: {"friendship": {"following": false, "outgoing_request": false}, "pk": pk}
        }
        PullToRefresh {
            refreshing: list_loading && suggestionsModel.count == 0
            onRefresh: suggestions()
        }
    }

    Connections{
        target: instagram
        onSuggestionsFeedDataReady: {
            var data = JSON.parse(answer);
            suggestionsDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
