import QtQuick 2.3
import QtGraphicalEffects 1.0

Item {
    id: item

    property alias source: image.source
    property alias status: image.status

    width: image.implicitWidth
    height: image.implicitHeight

    Image {
        id: image
        anchors.fill: parent
        smooth: false
        visible: false
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width,height)
    }

    Image {
        id: mask
        source: Qt.resolvedUrl("../images/circle.png")
        anchors.fill: image
        smooth: true
        visible: false
        mipmap: true
    }

    OpacityMask {
        anchors.fill: image
        source: image
        maskSource: mask
    }
}
