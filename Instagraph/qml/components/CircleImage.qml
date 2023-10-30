import QtQuick 2.12
import Lomiri.Components 1.3
import QtGraphicalEffects 1.0

Item {
    id: item

    property alias source: image.source
    property alias status: image.status

    width: image.implicitWidth
    height: image.implicitHeight

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.1)
        radius: width/2
    }

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
