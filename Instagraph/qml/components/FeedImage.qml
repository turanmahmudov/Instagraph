import QtQuick 2.4
import Ubuntu.Components 1.3

Image {
    fillMode: Image.PreserveAspectCrop
    sourceSize: Qt.size(width,height)
    asynchronous: true
    cache: true // maybe false
    smooth: false

    layer.enabled: false //status != Image.Ready
    layer.effect: Rectangle {
        anchors.fill: parent
        color: "#efefef"
    }
}
