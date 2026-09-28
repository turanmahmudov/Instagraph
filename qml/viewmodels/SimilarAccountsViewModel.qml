import QtQuick 2.12
import Instagram 1.0

/**
 * SimilarAccountsViewModel - ViewModel for the similar accounts on OtherUserPage
 *
 * Handles the accounts Instagram suggests next to a profile
 */
Item {
    id: viewModel
    visible: false

    property var userId

    property ListModel accountsModel: ListModel {}
    property bool isLoading: false

    function load() {
        accountsModel.clear();
        isLoading = true;
        instagram.getSuggestedUser(userId);
    }

    Connections {
        target: instagram
        enabled: viewModel.isLoading
        function onSuggestedUserDataReady(answer) {
            isLoading = false;
            var data = JSON.parse(answer);
            var users = data && data.users ? data.users : [];
            for (var i = 0; i < users.length; i++) {
                accountsModel.append({
                    "user": users[i]
                });
            }
        }
    }
}
