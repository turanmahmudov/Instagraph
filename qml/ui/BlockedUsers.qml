// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.1

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: blockeduserspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeaderItem {
        title: i18n.tr("Blocked Users")
    }

    function userBlockedListDataFinished(data) {
        blockedUsersModel.clear()

        worker.sendMessage({'feed': 'BlockedUsersPage', 'obj': data.blocked_list, 'model': blockedUsersModel, 'clear_model': true})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/SimpleWorker.js"
        onMessage: {
        }
    }

    Component.onCompleted: {
        getUserBlockedList();
    }

    function getUserBlockedList()
    {
        instagram.getBlockedUserList();
    }

    ListModel {
        id: blockedUsersModel
    }

    UsersListView {
        id: blockedUsersList
        model: blockedUsersModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(blockeduserspage, PagesConstants.user, {usernameId: user_id})
        }
        PullToRefresh {
            refreshing: list_loading && blockedUsersModel.count == 0
            onRefresh: {
                list_loading = true
                getUserBlockedList()
            }
        }
    }

    Connections{
        target: instagram
        onBlockedUserListDataReady: {
            var data = JSON.parse(answer);
            userBlockedListDataFinished(data);
        }
    }
}
