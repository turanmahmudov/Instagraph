import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3

import ".."

Item {
    signal popupClicked

    Layout.minimumWidth: width
    Layout.preferredWidth: width

    LineIcon {
        anchors.verticalCenter: parent.verticalCenter
        name: IconsConstants.more
        color: styleApp.common.iconActiveColor
        iconSize: units.gu(2)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: popupClicked()
    }
}
