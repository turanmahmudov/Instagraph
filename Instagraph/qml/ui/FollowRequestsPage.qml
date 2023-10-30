import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: followrequestspage

    header: PageHeaderItem {
        title: i18n.tr("Follow Requests")
    }

    property bool list_loading: false

    property var last_friendship_action_done

    function pendingFriendshipsDataFinished(data) {
        worker.sendMessage({'feed': 'FollowRequestsPage', 'obj': data.users, 'model': followrequestsModel, 'clear_model': true})

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
        followRequests();
    }

    function followRequests()
    {
        followrequestsModel.clear()
        list_loading = true
        instagram.pendingFriendships();
    }

    ListModel {
        id: followrequestsModel
    }

    ListView {
        id: followRequestsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: followrequestspage.header.bottom
        }

        clip: true
        cacheBuffer: followrequestspage.height*2
        model: followrequestsModel
        delegate: ListItem {
            id: searchUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToCurrent(followrequestspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
            }

            property bool is_friendship_approved: false

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: UserRowSlot {
                    id: label
                    width: parent.width - (is_friendship_approved ? followButton.width : buttons.width)
                }

                Row {
                    id: buttons
                    spacing: units.gu(1)

                    Button {
                        color: LomiriColors.blue
                        text: i18n.tr("Confirm")

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        onClicked: {
                            last_friendship_action_done = pk
                            instagram.approveFriendship(pk)
                        }
                    }

                    Button {
                        color: LomiriColors.lightGrey
                        text: i18n.tr("Delete")

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        onClicked: {
                            last_friendship_action_done = pk
                            instagram.rejectFriendship(pk)
                        }
                    }

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }

                Connections {
                    target: instagram
                    onApproveFriendshipDataReady: {
                        var data = JSON.parse(answer)
                        if (data.status === "ok" && last_friendship_action_done === pk) {
                            is_friendship_approved = true

                            buttons.width = 0
                            buttons.visible = false

                            followButton.friendship_var = data.friendship_status
                            followButton.init()
                            followButton.visible = true
                        }
                    }
                    onRejectFriendshipDataReady: {
                        var data = JSON.parse(answer)
                        if (data.status === "ok" && last_friendship_action_done === pk) {
                            followrequestsModel.remove(index)
                        }
                    }
                }

                FollowComponent {
                    id: followButton
                    visible: false
                    height: units.gu(3.5)
                    friendship_var: {"following": false, "outgoing_request": false}
                    userId: pk
                    just_icon: false

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
    }

    Connections{
        target: instagram
        onPendingFriendshipsDataReady: {
            var data = JSON.parse(answer);
            pendingFriendshipsDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
