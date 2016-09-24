import QtQuick 2.4
import Ubuntu.Components 1.3

Column {
    width: parent.width

    property bool icon: false
    property var iconName
    property var iconSource
    property var iconColor

    property var title
    property var description

    Item {
        width: parent.width
        height: units.gu(4)
    }

    Item {
        visible: icon
        width: parent.width
        height: units.gu(6)

        Icon {
            width: units.gu(6)
            height: width
            name: iconName ? iconName : ""
            color: iconColor ? iconColor : "#003569"
            source: iconName ? "image://theme/%1".arg(iconName) : iconSource
            anchors.centerIn: parent
        }
    }

    Item {
        visible: icon
        width: parent.width
        height: units.gu(2)
    }

    Item {
        visible: title
        width: parent.width
        height: units.gu(2)

        Label {
            text: title
            font.weight: Font.DemiBold
            fontSize: "large"
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
        }
    }

    Item {
        visible: title
        width: parent.width
        height: units.gu(1)
    }

    Item {
        visible: description
        width: parent.width
        height: empDescription.height

        Label {
            id: empDescription
            width: parent.width - units.gu(2)
            text: description
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
        }
    }

    Item {
        visible: description
        width: parent.width
        height: units.gu(1)
    }
}
