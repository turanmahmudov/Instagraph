import QtQuick 2.12
import Lomiri.Components 1.3

AbstractButton {
    id: rootItem

    property string iconName: ""

    Column {
        spacing: units.gu(2)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: previewImg
            anchors.horizontalCenter: parent.horizontalCenter
            width: units.gu(5)
            height: width
            radius: width * 0.5
            color: Qt.rgba(0, 0, 0, 0.5)

            Icon {
                anchors.centerIn: parent
                width: units.gu(3)
                height: width
                color: "#ffffff"
                source: "image://theme/%1".arg(iconName)
            }
        }
    }
}
