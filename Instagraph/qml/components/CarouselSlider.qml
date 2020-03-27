import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.6
import QtGraphicalEffects 1.0

import "../js/Helper.js" as Helper

ListView {
    id: listViewCarousel

    property var bestImage

    snapMode: ListView.SnapOneItem
    orientation: Qt.Horizontal
    highlightMoveDuration: UbuntuAnimation.FastDuration
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightFollowsCurrentItem: true
    clip: true

    delegate: Item {
        width: listViewCarousel.width
        height: listViewCarousel.height
        clip: true

        property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

        FeedImage {
            id: feed_image
            width: parent.width
            height:parent.width/bestImage.width*bestImage.height
            source: bestImage.url
        }

        Icon {
            id: animatingLikeIcon
            width: 0
            height: width
            anchors.centerIn: feed_image
            name: "like"
            color: theme.palette.highlighted.baseText
            opacity: 0

            NumberAnimation on width {
                id: sizeAnimation
                from: 0
                to: units.gu(6)
                duration: 750
                easing.type: Easing.InOutQuad
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

            function sizeAnimation() {
                sizeAnimation.start()
            }

            function opacityAnimation() {
                opacityAnimation.start()
            }
        }

        Icon {
            id: is_video_icon
            width: units.gu(3)
            height: width
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(2)
            }
            visible: false
            name: "camcorder"
            color: theme.palette.highlighted.baseText
        }
        DropShadow {
            anchors.fill: is_video_icon
            source: is_video_icon
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8.0
            samples: 15
            color: theme.palette.normal.base
            visible: media_type === 2
        }

        MediaPlayer {
            id: player
            source: video_url
            autoLoad: false
            autoPlay: false
            loops: MediaPlayer.Infinite
        }
        VideoOutput {
            id: videoOutput
            source: player
            fillMode: VideoOutput.PreserveAspectCrop
            width: 800
            height: 600
            anchors.fill: parent
            visible: media_type == 2
        }

        MouseArea {
            anchors {
                fill: parent
            }
            onClicked: {
                if (media_type === 2) {
                    console.log('PLAY VIDEO')
                    console.log(video_url)
                    if (player.playbackState == MediaPlayer.PlayingState) {
                        player.stop()
                    } else {
                        player.play()
                    }
                }
            }
            onDoubleClicked: {
                animatingLikeIcon.sizeAnimation()
                animatingLikeIcon.opacityAnimation()

                last_like_id = id;
                instagram.like(id);
            }
        }

        Connections {
            target: instagram
            onLikeDataReady: {
                if (JSON.parse(answer).status === "ok" && last_like_id === id) {
                    imagelikeicon.color = UbuntuColors.red;
                    imagelikeicon.name = "like";
                }
            }
            onUnLikeDataReady: {
                if (JSON.parse(answer).status === "ok" && last_like_id === id) {
                    imagelikeicon.color = "";
                    imagelikeicon.name = "unlike";
                }
            }
        }
    }
}
