import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import QtGraphicalEffects 1.0

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Item {

    function startLikeAnimation() {
        animatingLikeIcon.sizeAnimationFunction()
        animatingLikeIcon.opacityAnimationFunction()
    }

    property var bestImage: typeof carousel_media_obj.media !== 'undefined' && carousel_media_obj.media.length > 0 ?
                                Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width) :
                                Helper.getBestImage(images_obj.candidates, parent.width)

    FeedImage {
        id: feed_image
        width: parent.width
        height:parent.width/bestImage.width*bestImage.height
        source: bestImage.url
    }

    LineIcon {
        id: animatingLikeIcon
        anchors.centerIn: feed_image
        name: "\ueadf"
        color: "#ffffff"
        iconSize: units.gu(0.1)
        opacity: 0

        NumberAnimation on iconSize {
            id: sizeAnimation
            from: units.gu(0.1)
            to: units.gu(6)
            duration: 750
            easing.type: Easing.Linear
            running: false
        }

        NumberAnimation on opacity {
            id: opacityAnimation
            from: 0
            to: 1
            duration: 750
            easing.type: Easing.InOutQuad
            running: false

            onRunningChanged: {
                if (!running) {
                    destroyTimer.start()
                }
            }
        }

        Timer {
            id: destroyTimer
            interval: 500
            running: false
            repeat: false
            onTriggered: {
                animatingLikeIcon.opacity = 0
            }
        }

        function sizeAnimationFunction() {
            sizeAnimation.start()
        }

        function opacityAnimationFunction() {
            opacityAnimation.start()
        }
    }

    LineIcon {
        id: is_video_icon
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(2)
        }
        visible: false
        name: "\uebe2"
        color: "#ffffff"
        iconSize: units.gu(2.4)
    }
    DropShadow {
        anchors.fill: is_video_icon
        source: is_video_icon
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8.0
        samples: 15
        color: "#80000000"
        visible: media_type === 2
    }

    LineIcon {
        id: is_carousel_icon
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            top: parent.top
            topMargin: units.gu(2)
        }
        visible: false
        name: "\ueac8"
        color: "#ffffff"
        iconSize: units.gu(2.4)
    }
    DropShadow {
        anchors.fill: is_carousel_icon
        source: is_carousel_icon
        horizontalOffset: 2
        verticalOffset: 2
        radius: 8.0
        samples: 15
        color: "#80000000"
        visible: media_type === 8
    }
}
