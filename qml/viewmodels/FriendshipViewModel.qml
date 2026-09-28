import QtQuick 2.12
import Instagram 1.0

/**
 * FriendshipViewModel - ViewModel for the friendship state on OtherUserPage
 *
 * Handles the relation to another user:
 * - Friendship status loading
 * - Follow, unfollow, block and unblock
 */
Item {
    id: viewModel
    visible: false

    property var userId

    property bool isLoaded: false
    property bool following: false
    property bool outgoingRequest: false
    property bool blocking: false
    property bool privateAccount: false

    readonly property bool canFollow: isLoaded && !following && !outgoingRequest && !blocking
    readonly property bool contentHidden: privateAccount && !following

    property bool isLoading: false
    property var pendingUserId: null

    signal friendshipLoaded
    signal blocked

    function loadFriendship() {
        isLoading = true;
        instagram.getFriendship(userId);
    }

    function follow() {
        pendingUserId = userId;
        instagram.follow(userId);
    }

    function unfollow() {
        pendingUserId = userId;
        instagram.unFollow(userId);
    }

    function block() {
        pendingUserId = userId;
        instagram.block(userId);
    }

    function unblock() {
        pendingUserId = userId;
        instagram.unBlock(userId);
    }

    Connections {
        target: instagram
        enabled: viewModel.isLoading || viewModel.pendingUserId !== null
        function onFriendshipDataReady(answer) {
            if (!isLoading) {
                return;
            }

            isLoading = false;

            var data = JSON.parse(answer);
            applyStatus(data);
            privateAccount = data.is_private === true;
            isLoaded = true;
            friendshipLoaded();
        }
        function onFollowDataReady(answer) {
            handleActionResponse(JSON.parse(answer));
        }
        function onUnfollowDataReady(answer) {
            handleActionResponse(JSON.parse(answer));
        }
        function onBlockDataReady(answer) {
            if (handleActionResponse(JSON.parse(answer)) && blocking) {
                blocked();
            }
        }
        function onUnBlockDataReady(answer) {
            handleActionResponse(JSON.parse(answer));
        }
    }

    function handleActionResponse(data) {
        if (pendingUserId === null || pendingUserId != userId || !data.friendship_status) {
            return false;
        }

        pendingUserId = null;
        applyStatus(data.friendship_status);
        return true;
    }

    function applyStatus(status) {
        following = status.following === true;
        outgoingRequest = status.outgoing_request === true;
        blocking = status.blocking === true;
    }
}
