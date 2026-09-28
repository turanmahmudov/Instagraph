import QtQuick 2.12
import Instagram 1.0

/**
 * MentionSuggestionsViewModel - ViewModel for MentionSuggestions
 *
 * Handles @mention suggestions:
 * - Autocomplete user list, loaded once on the first mention
 * - Local filtering by username and full name prefix
 */
Item {
    id: viewModel
    visible: false

    readonly property int maxSuggestions: 5

    property ListModel suggestionsModel: ListModel {}

    property var users: []
    property bool loaded: false
    property bool isLoading: false
    property string query: ""

    function filter(newQuery) {
        query = newQuery;
        if (!loaded && !isLoading) {
            isLoading = true;
            instagram.getAutocompleteUserList();
        }
        applyFilter();
    }

    function applyFilter() {
        suggestionsModel.clear();
        if (!loaded) {
            return;
        }

        var prefix = query.toLowerCase();
        for (var i = 0; i < users.length && suggestionsModel.count < maxSuggestions; i++) {
            var user = users[i];
            var username = (user.username || "").toLowerCase();
            var fullName = (user.full_name || "").toLowerCase();
            if (username.indexOf(prefix) === 0 || fullName.indexOf(prefix) === 0) {
                suggestionsModel.append({
                    "username": user.username,
                    "full_name": user.full_name || "",
                    "profile_pic_url": user.profile_pic_url || ""
                });
            }
        }
    }

    Connections {
        target: instagram
        enabled: viewModel.isLoading
        function onAutocompleteUserListDataReady(answer) {
            isLoading = false;
            var data = JSON.parse(answer);
            users = data && data.users ? data.users : [];
            loaded = true;
            applyFilter();
        }
    }
}
