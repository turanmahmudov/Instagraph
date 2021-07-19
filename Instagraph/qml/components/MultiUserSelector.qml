import QtQuick 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Components.Popups 1.3

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

AbstractButton {
    id: multiUserSelector

    Row {
        anchors.fill: parent
        spacing: units.gu(0.5)

        Label {
            text: userPage.header.title
            fontSize: "large"
            wrapMode: Text.WordWrap
            anchors.verticalCenter: parent.verticalCenter
        }

        LineIcon {
            name: "\uea58"
            iconSize: units.gu(1.5)
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
