import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: refresh
    height: units.gu(5)
    width: parent.width
    visible: false

    anchors {
        horizontalCenter: parent.horizontalCenter
        top: parent.top
        margins: units.gu(20)
    }
    ActivityIndicator {
        id: loading
        objectName: "LoadingSpinner"
        anchors.centerIn: parent
        running: refresh.visible
        z: 1
    }
}
