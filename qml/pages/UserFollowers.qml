import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"

PageItem {
    id: followerspage

    header: PageHeaderItem {
        title: i18n.tr("Followers")
    }

    property var userId

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool list_loading: false
    property bool clear_models: true

    property bool isPullToRefresh: true

    ListModel {
        id: userFollowersModel
    }

    ListView {
        id: userFollowersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: followerspage.header.bottom
        }
        model: userFollowersModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(followerspage, PagesConstants.user, {usernameId: user.pk})
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) getUserFollowers(next_max_id)
        }
        PullToRefresh {
            refreshing: list_loading && userFollowersModel.count === 0
            onRefresh: {
                isPullToRefresh = true
                getUserFollowers('')
            }
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/UserWorker.js"
    }

    function getUserFollowers(next_id) {
        list_loading = true
        clear_models = false

        if (!next_id) {
            userFollowersModel.clear()
            next_max_id = ""
            clear_models = true
        }

        instagram.getFollowers(userId, next_id)
    }

    function userFollowersDataFinished(data) {
        if (!data) return

        isPullToRefresh = false
        list_loading = false

        if (next_max_id === data.next_max_id) return
        
        next_max_id = typeof data.next_max_id != 'undefined' ? data.next_max_id : ""
        more_available = typeof data.next_max_id != 'undefined'
        next_coming = true

        worker.sendMessage(
            {
                items: data.users,
                model: userFollowersModel,
                clear: clear_models
            }
        )

        next_coming = false
        list_loading = false
    }

    Connections{
        target: instagram
        onFollowersDataReady: {
            var data = JSON.parse(answer)
            userFollowersDataFinished(data)
        }
    }

    Component.onCompleted: {
        getUserFollowers()
    }
}
