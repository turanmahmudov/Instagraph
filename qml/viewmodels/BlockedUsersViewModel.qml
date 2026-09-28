import QtQuick 2.12
import Instagram 1.0

/**
 * BlockedUsersViewModel - ViewModel for BlockedUsers
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: false

    dataKey: "blocked_list"

    function load(nextId) {
        beginLoad(nextId);
        instagram.getBlockedUserList();
    }

    Connections {
        target: instagram
        function onBlockedUserListDataReady(answer) {
            handleResponse(answer);
        }
    }
}
