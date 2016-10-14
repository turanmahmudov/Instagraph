import QtQuick 2.4
import Ubuntu.Components 1.3

Column {
    width: parent.width
    spacing: 0

    property bool icon: false
    property string iconName: ""
    property string iconSource
    property string iconColor

    property string title
    property string description
    property string description2

    Item {
        width: parent.width
        height: units.gu(4)
    }

    Item {
        visible: icon
        width: parent.width
        height: icon ? units.gu(6) : 0

        Icon {
            width: units.gu(6)
            height: width
            name: iconName.length > 0 ? iconName : ""
            color: iconColor.length > 0 ? iconColor : "#003569"
            source: iconName.length > 0 ? "image://theme/%1".arg(iconName) : iconSource
            anchors.centerIn: parent
        }
    }

    Item {
        visible: icon
        width: parent.width
        height: icon ? units.gu(2) : 0
    }

    Item {
        visible: title.length > 0
        width: parent.width
        height: title.length > 0 ? units.gu(2) : 0

        Label {
            text: title
            font.weight: Font.DemiBold
            fontSize: "large"
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
        }
    }

    Item {
        visible: title.length > 0
        width: parent.width
        height: title.length > 0 ? units.gu(1) : 0
    }

    Item {
        visible: description.length > 0
        width: parent.width
        height: description.length > 0 ? empDescription.height : 0

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
        visible: description.length > 0
        width: parent.width
        height: description.length > 0 ? units.gu(1) : 0
    }

    Item {
        visible: description2.length > 0
        width: parent.width
        height: description2.length > 0 ? empDescription2.height : 0

        Label {
            id: empDescription2
            width: parent.width - units.gu(2)
            text: description2
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            anchors.centerIn: parent
        }
    }

    Item {
        visible: description2.length > 0
        width: parent.width
        height: description2.length > 0 ? units.gu(1) : 0
    }
}
