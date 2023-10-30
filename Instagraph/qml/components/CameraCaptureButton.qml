import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    width: parent.width
    height: parent.height

    Rectangle {
        width: parent.width
        height: width
        radius: width/2
        border.color: takePhotoMode == 1 ? Qt.darker(LomiriColors.blue, 1) : Qt.darker(LomiriColors.red, 1)

        Rectangle {
            anchors.centerIn: parent
            width: units.gu(6)
            height: width
            color: takePhotoMode == 1 ? Qt.darker(LomiriColors.blue, 1) : Qt.darker(LomiriColors.red, 1)
            radius: width/2
            border.color: takePhotoMode == 1 ? Qt.darker(LomiriColors.blue, 1) : Qt.darker(LomiriColors.red, 1)
        }
    }
}
