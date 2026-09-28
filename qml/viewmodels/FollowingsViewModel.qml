import QtQuick 2.12
import Instagram 1.0

/**
 * FollowingsViewModel - ViewModel for UserFollowings
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: true

    property var userId

    function load(nextId) {
        beginLoad(nextId);
        instagram.getFollowing(userId, nextId);
    }

    Connections {
        target: instagram
        function onFollowingDataReady(answer) {
            handleResponse(answer);
        }
    }
}
