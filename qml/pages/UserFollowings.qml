import QtQuick 2.12
import Lomiri.Components 1.3

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"

PageItem {
    id: followingspage

    header: PageHeaderItem {
        title: i18n.tr("Followings")
    }

    property var userId

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool list_loading: false
    property bool clear_models: true

    property bool isPullToRefresh: true

    ListModel {
        id: userFollowingsModel
    }

    ListView {
        id: userFollowingsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: followingspage.header.bottom
        }
        model: userFollowingsModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(followingspage, PagesConstants.user, {usernameId: user.pk})
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) getUserFollowings(next_max_id)
        }
        PullToRefresh {
            refreshing: list_loading && userFollowingsModel.count === 0
            onRefresh: {
                isPullToRefresh = true
                getUserFollowings('')
            }
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/UserWorker.js"
    }

    function getUserFollowings(next_id) {
        list_loading = true
        clear_models = false

        if (!next_id) {
            userFollowingsModel.clear()
            next_max_id = ""
            clear_models = true
        }

        instagram.getFollowing(userId, next_id);
    }

    function userFollowingsDataFinished(data) {
        if (!data) return

        if (next_max_id === data.next_max_id) return

        next_max_id = typeof data.next_max_id != 'undefined' ? data.next_max_id : ""
        more_available = typeof data.next_max_id != 'undefined'
        next_coming = true;

        worker.sendMessage(
            {
                items: data.users,
                model: userFollowingsModel,
                clear: clear_models
            }
        )

        next_coming = false
        list_loading = false
    }

    Connections{
        target: instagram
        onFollowingDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
    }

    Component.onCompleted: {
        getUserFollowings()
    }
}
