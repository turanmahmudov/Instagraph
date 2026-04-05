import QtQuick 2.12
import "../Constants"
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import ".."

Item {
    signal sendMessageClicked(string text)
    signal sendLikeClicked

    height: units.gu(5)

    Row {
        width: parent.width
        spacing: units.gu(1)

        TextField {
            id: addMessageField
            width: parent.width - addMessageButton.width - sendLikeButton.width - units.gu(2)
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: i18n.tr("Write a message...")
            onAccepted: sendMessageClicked(addMessageField.text)
        }

        Item {
            id: sendLikeButton
            height: units.gu(3)
            width: height
            anchors.verticalCenter: parent.verticalCenter

            LineIcon {
                anchors.centerIn: parent
                name: IconsConstants.unliked
                color: LomiriColors.red
                iconSize: units.gu(2.4)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: sendLikeClicked()
            }
        }

        Button {
            id: addMessageButton
            anchors.verticalCenter: parent.verticalCenter
            color: LomiriColors.green
            text: i18n.tr("Send")
            onClicked: sendMessageClicked(addMessageField.text)
        }
    }

    function clearTextField() {
        addMessageField.text = "";
    }
}
