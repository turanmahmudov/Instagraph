import QtQuick 2.12
import Lomiri.Components 1.3
import QtMultimedia 5.12
import QtGraphicalEffects 1.0

import "Media"
import "../js/Helper.js" as Helper

ListView {
    id: listViewCarousel

    property var bestImage
    property var dataArray: []

    snapMode: ListView.SnapOneItem
    orientation: Qt.Horizontal
    highlightMoveDuration: LomiriAnimation.FastDuration
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightFollowsCurrentItem: true
    clip: true
    model: dataArray
    cacheBuffer: width * 2

    delegate: Item {
        width: listViewCarousel.width
        height: listViewCarousel.height
        clip: true

        property var carousel_media_obj: {
            "media": []
        }
        property var images_obj: modelData.image_versions2
        property int media_type: modelData.media_type

        MediaItem {
            id: mediaItem
            anchors.fill: parent
            bestImage: Helper.getBestImage(images_obj.candidates, width)
        }

        MediaPlayer {
            id: player
            source: modelData.video_url || ""
            autoLoad: false
            autoPlay: false
            loops: MediaPlayer.Infinite
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            source: player
            fillMode: VideoOutput.PreserveAspectCrop
            visible: media_type === 2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (media_type === 2) {
                    if (player.playbackState === MediaPlayer.PlayingState) {
                        player.stop();
                    } else {
                        player.play();
                    }
                }
            }
            onDoubleClicked: {
                mediaItem.startLikeAnimation();
            }
        }
    }
}
