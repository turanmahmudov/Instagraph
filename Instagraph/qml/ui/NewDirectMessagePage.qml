import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: newdirectmessagepage

    property bool list_loading: false

    header: PageHeader {
        title: i18n.tr("New Message")
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: newdirectmessagepage.header.bottom
        visible: instagram.busy || list_loading
    }

    Item {
        id: addMessageItem
        height: units.gu(5)
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        Row {
            width: parent.width
            spacing: units.gu(1)

            TextField {
                id: addMessageField
                width: parent.width - addMessageButton.width - sendLikeButton.width - units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: i18n.tr("Write a message...")
                onAccepted: {
                    sendMessage(addMessageField.text)
                }
            }

            Icon {
                id: sendLikeButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.red
                height: units.gu(3)
                width: height
                name: "unlike"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sendLike()
                    }
                }
            }

            Button {
                id: addMessageButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.green
                text: i18n.tr("Send")
                onClicked: {
                    sendMessage(addMessageField.text)
                }
            }
        }
    }
}
