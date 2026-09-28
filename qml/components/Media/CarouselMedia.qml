import QtQuick 2.12
import Lomiri.Components 1.3

import ".."

Item {
    id: carouselmedia

    signal doubleClicked

    CarouselSlider {
        id: carouselSlider
        width: parent.width
        height: parent.height - units.gu(2)
        dataArray: carousel_media_obj.media

        MouseArea {
            anchors.fill: parent

            onDoubleClicked: {
                carouselmedia.doubleClicked();
            }
        }
    }

    Row {
        id: slideIndicator
        height: units.gu(2)
        spacing: units.gu(0.5)
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }

        Repeater {
            model: carousel_media_obj.media.length
            delegate: Item {
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(1)
                height: units.gu(1)
                Rectangle {
                    property bool active: carouselSlider.currentIndex == index
                    height: active ? units.gu(0.9) : units.gu(0.7)
                    width: height
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: active ? LomiriColors.blue : styleApp.common.iconActiveColor
                    Behavior on color {
                        ColorAnimation {
                            duration: LomiriAnimation.FastDuration
                        }
                    }
                }
            }
        }
    }
}
