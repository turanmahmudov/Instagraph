import QtQuick 2.12
import Instagram 1.0

/**
 * FollowRequestsViewModel - ViewModel for FollowRequestsPage
 *
 * Handles follow requests:
 * - Pending requests loading
 * - Approve and reject
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: false

    property var pendingUserId: null

    signal requestApproved(var userId, var friendship)
    signal requestRejected(var userId)

    function load() {
        beginLoad('');
        instagram.getPendingFriendships();
    }

    function approve(userId) {
        pendingUserId = userId;
        instagram.approveFriendship(userId);
    }

    function reject(userId) {
        pendingUserId = userId;
        instagram.rejectFriendship(userId);
    }

    Connections {
        target: instagram
        function onPendingFriendshipsDataReady(answer) {
            handleResponse(answer);
        }
        function onApproveFriendshipDataReady(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok" && pendingUserId !== null) {
                requestApproved(pendingUserId, data.friendship_status);
                pendingUserId = null;
            }
        }
        function onRejectFriendshipDataReady(answer) {
            var data = JSON.parse(answer);
            if (data.status === "ok" && pendingUserId !== null) {
                var userId = pendingUserId;
                pendingUserId = null;
                for (var i = 0; i < userListModel.count; i++) {
                    if (userListModel.get(i).user.pk == userId) {
                        userListModel.remove(i);
                        break;
                    }
                }
                requestRejected(userId);
            }
        }
    }
}
