import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import Lomiri.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: usersfollowingspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    header: PageHeaderItem {
        title: i18n.tr("Followings")
    }

    function userFollowingsDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = typeof data.next_max_id != 'undefined' ? data.next_max_id : ""
            more_available = typeof data.next_max_id != 'undefined'
            next_coming = true;

            worker.sendMessage({'feed': 'UserFollowingsPage', 'obj': data.users, 'model': userFollowingsModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getUserFollowings();
    }

    function getUserFollowings(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowingsModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getFollowing(userId, next_id);
    }

    ListModel {
        id: userFollowingsModel
    }

    UsersListView {
        id: userFollowingsList
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) getUserFollowings(next_max_id)
        }
        model: userFollowingsModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(usersfollowingspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk})
            followButton: true
            followData: {"friendship": {"following": true, "outgoing_request": false}, "pk": pk}
        }
        PullToRefresh {
            refreshing: list_loading && userFollowingsModel.count == 0
            onRefresh: {
                list_loading = true
                getUserFollowings()
            }
        }
    }

    Connections{
        target: instagram
        onFollowingDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
    }
}
