import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.1
import QtMultimedia 5.4

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: blockeduserspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
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
        instagram.getUserBlockedList();
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: blockeduserspage.header.bottom
        visible: instagram.busy || list_loading
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
        cacheBuffer: parent.height*2
        model: blockedUsersModel
        delegate: ListItem {
            id: blockedUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: user_id});
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: parent.width - units.gu(5)

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: profile_pic_url
                    }

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                        }

                        Text {
                            text: full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }
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
        onUserBlockedListDataReady: {
            var data = JSON.parse(answer);
            userBlockedListDataFinished(data);
        }
    }
}
