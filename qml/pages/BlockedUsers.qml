import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"

PageItem {
    id: blockeduserspage

    header: PageHeaderItem {
        title: i18n.tr("Blocked Users")
    }

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    ListModel {
        id: blockedUsersModel
    }

    ListView {
        id: blockedUsersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: blockeduserspage.header.bottom
        }
        model: blockedUsersModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(blockeduserspage, PagesConstants.user, {usernameId: user.pk})
        }
        PullToRefresh {
            refreshing: list_loading && blockedUsersModel.count == 0
            onRefresh: {
                list_loading = true
                getUserBlockedList()
            }
        }
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/UserWorker.js"
    }

    function getUserBlockedList()
    {
        instagram.getBlockedUserList();
    }

    function userBlockedListDataFinished(data) {
        blockedUsersModel.clear()

        worker.sendMessage(
            {
                items: data.blocked_list,
                model: blockedUsersModel,
                clear: true
            }
        )

        list_loading = false
    }

    Connections{
        target: instagram
        onBlockedUserListDataReady: {
            var data = JSON.parse(answer);
            userBlockedListDataFinished(data);
        }
    }

    Component.onCompleted: {
        getUserBlockedList();
    }
}
