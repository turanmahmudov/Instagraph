import QtQuick 2.12
import Instagram 1.0

/**
 * SuggestionsViewModel - ViewModel for SuggestionsPage
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: false

    function load(nextId) {
        beginLoad(nextId);
        instagram.getSuggestions();
    }

    Connections {
        target: instagram
        function onSuggestionsFeedDataReady(answer) {
            if (!isLoading)
                return;
            var data = JSON.parse(answer);
            var suggestions = data.suggested_users ? data.suggested_users.suggestions : [];
            handleResponse({
                users: suggestions.map(function (suggestion) {
                    var user = suggestion.user;
                    user.friendship = {
                        "following": false,
                        "outgoing_request": false
                    };
                    return user;
                })
            });
        }
    }
}
