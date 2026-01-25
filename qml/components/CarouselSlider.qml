import QtQuick 2.12
import Lomiri.Components 1.3
import QtMultimedia 5.12
import QtGraphicalEffects 1.0

import "../js/Helper.js" as Helper

ListView {
    id: listViewCarousel

    property var bestImage

    property var dataArray: []

    ListModel {
        id: listModel

        Component.onCompleted: {
            for(var i = 0; i < dataArray.length; i++) {
                listModel.append(dataArray[i]);
            }
        }
    }

    snapMode: ListView.SnapOneItem
    orientation: Qt.Horizontal
    highlightMoveDuration: LomiriAnimation.FastDuration
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightFollowsCurrentItem: true
    clip: true
    model: listModel

    delegate: MediaItem {
        width: listViewCarousel.width
        height: listViewCarousel.height

        clip: true

        bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

        MediaItem {
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
        }
    }
}
