import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: followrequestspage

    header: PageHeader {
        title: i18n.tr("Follow Requests")
    }

    property bool list_loading: false

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

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: followrequestspage.header.bottom
        visible: instagram.busy
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
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
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
                    width: parent.width - buttons.width

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: profile_pic_url
                    }

                    Column {
                        width: parent.width - units.gu(6)
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

                Row {
                    id: buttons
                    spacing: units.gu(1)

                    Button {
                        color: UbuntuColors.blue
                        text: i18n.tr("Confirm")

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        onClicked: {

                        }
                    }

                    Button {
                        color: UbuntuColors.lightGrey
                        text: i18n.tr("Delete")

                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        onClicked: {

                        }
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onPendingFriendshipsDataReady: {
            console.log(answer)
            var data = JSON.parse(answer);
            pendingFriendshipsDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
