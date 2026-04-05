import QtQuick 2.12
import Lomiri.Components 1.3

import ".."

Column {
    width: parent.width
    spacing: units.gu(1)

    property string title: ""
    property string subtitle: ""

    Item {
        width: parent.width
        height: units.gu(2)
    }

    Rectangle {
        width: parent.width
        height: units.gu(0.1)
        color: styleApp.common.baseBorderColor
    }

    Item {
        width: parent.width
        height: units.gu(1)
    }

    Column {
        width: parent.width - units.gu(4)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(0.5)

        Label {
            text: title
            font.weight: Font.DemiBold
            fontSize: "large"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            text: subtitle
            font.weight: Font.Light
            fontSize: "medium"
            color: styleApp.common.text2Color
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Item {
        width: parent.width
        height: units.gu(2)
    }
}
