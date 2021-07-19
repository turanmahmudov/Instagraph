import QtQuick 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import QtGraphicalEffects 1.0

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: multipleAccountsSwitcher

    property bool showAddAccount: false

    header: PageHeaderItem {
        title: i18n.tr("Switch Accounts")
    }

    function init() {
        allUsersModel.clear()

        var allUsers = Storage.getAccounts()
        for (var i = 0; i < allUsers.length; i++) {
            var user = {
                'username': allUsers[i].username,
                'profile_pic_url': allUsers[i].profilePicUrl,
                'isUser': true
            }
            allUsersModel.append(user)
        }

        if (showAddAccount) {
            var action = {
                'actionName': i18n.tr("Add Account"),
                'actionIcon': '\uea61',
                'isUser': false
            }
            allUsersModel.append(action)
        }
    }

    ListModel {
        id: allUsersModel
    }

    ListView {
        id: allUsersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: multipleAccountsSwitcher.header.bottom
        }

        model: allUsersModel
        delegate: ListItem {
            id: allUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                if (isUser) {
                    Scripts.switchAccount(username)
                    bottomEdge.collapse()
                } else {
                    Scripts.logOutWithoutRemoving()
                    bottomEdge.collapse()
                }
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Loader {
                    active: true
                    visible: true
                    asynchronous: false
                    sourceComponent: isUser ? userRow : actionRow
                }

                Component {
                    id: userRow
                    Row {
                        id: label
                        width: parent.width - units.gu(2)
                        spacing: units.gu(1)

                        CircleImage {
                            width: units.gu(5)
                            height: width
                            source: profile_pic_url
                        }

                        Text {
                            text: username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                            color: styleApp.common.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Component {
                    id: actionRow
                    Row {
                        id: label
                        width: parent.width - units.gu(2)
                        spacing: units.gu(1)

                        LineIcon {
                            name: actionIcon
                            iconSize: units.gu(3)
                            width: units.gu(5)
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: actionName
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                            color: styleApp.common.textColor
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true

                    color: UbuntuColors.blue
                    width: units.gu(1)
                    height: width
                    radius: width/2

                    visible: isUser && username == activeUsername
                }
            }
        }
    }
}
