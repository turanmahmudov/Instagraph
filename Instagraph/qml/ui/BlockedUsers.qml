import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

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
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
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

    ListView {
        id: blockedUsersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: blockeduserspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height
        model: blockedUsersModel
        delegate: ListItem {
            id: blockedUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToCurrent(blockeduserspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: user_id});
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: UserRowSlot {
                    id: label
                    width: parent.width - units.gu(5)
                }
            }

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
