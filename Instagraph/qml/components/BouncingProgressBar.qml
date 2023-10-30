import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    height: units.dp(3)
    width: parent.width

    onVisibleChanged: visible ? animation.start() : animation.stop()

    Rectangle {
        id: rectangle
        anchors.fill: parent
        color: LomiriColors.blue
        visible: animation.running
    }

    SequentialAnimation {
        id: animation
        loops: Animation.Infinite

        ParallelAnimation {
            PropertyAnimation { target: rectangle; property: "anchors.leftMargin"; from: 0; to: width * 7/8; duration: 1000; easing.type: Easing.InOutQuad }
            PropertyAnimation { target: rectangle; property: "anchors.rightMargin"; from: width * 7/8; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
        }
        ParallelAnimation {
            PropertyAnimation { target: rectangle; property: "anchors.leftMargin"; from: width * 7/8; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
            PropertyAnimation { target: rectangle; property: "anchors.rightMargin"; from: 0; to: width * 7/8; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }
}
