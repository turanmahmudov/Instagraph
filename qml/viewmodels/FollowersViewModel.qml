import QtQuick 2.12
import Instagram 1.0

/**
 * FollowersViewModel - ViewModel for UserFollowers
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: true

    property var userId

    function load(nextId) {
        beginLoad(nextId);
        instagram.getFollowers(userId, nextId);
    }

    Connections {
        target: instagram
        function onFollowersDataReady(answer) {
            handleResponse(answer);
        }
    }
}
