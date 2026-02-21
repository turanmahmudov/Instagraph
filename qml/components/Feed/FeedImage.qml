import QtQuick 2.12
import ".."
import Lomiri.Components 1.3

Item {
    id: container

    property alias source: image.source
    property alias fillMode: image.fillMode
    property alias sourceSize: image.sourceSize
    property alias status: image.status

    Rectangle {
        anchors.fill: parent
        color: styleApp.common.backgroundColor
        visible: image.status !== Image.Ready

        ActivityIndicator {
            anchors.centerIn: parent
            running: image.status === Image.Loading
        }
    }

    Image {
        id: image
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width, height)
        asynchronous: true
        cache: true
        smooth: false
    }
}
