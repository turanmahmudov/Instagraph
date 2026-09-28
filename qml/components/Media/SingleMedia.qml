import QtQuick 2.12
import Lomiri.Components 1.3
import QtMultimedia 5.12

import ".."
import "../Constants"

MediaItem {
    id: singlemedia

    signal doubleClicked

    Loader {
        id: videoLoader
        anchors.fill: parent
        active: enableVideoPlayback && media_type === 2
        asynchronous: true

        sourceComponent: Item {
            anchors.fill: parent

            MediaPlayer {
                id: videoPlayer
                source: video_url || ""
                autoLoad: false
                autoPlay: false
                loops: MediaPlayer.Infinite
            }

            VideoOutput {
                id: videoOutput
                anchors.fill: parent
                source: videoPlayer
                fillMode: VideoOutput.PreserveAspectCrop
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (videoPlayer.playbackState === MediaPlayer.PlayingState) {
                        videoPlayer.pause();
                    } else {
                        videoPlayer.play();
                    }
                }
                onDoubleClicked: {
                    singlemedia.doubleClicked();
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !videoLoader.active

        onClicked: {
            // If it's a carousel item (media_type 8) and showCarousel is false, open SinglePhoto page
            if (media_type === 8 && !showCarousel) {
                pageLayout.pushToNext(currentPage, PagesConstants.photo, {
                    photoId: id
                });
            } else
            // If it's a video (media_type 2) and enableVideoPlayback is false, open SinglePhoto page
            if (media_type === 2 && !enableVideoPlayback) {
                pageLayout.pushToNext(currentPage, PagesConstants.photo, {
                    photoId: id
                });
            }
        }

        onDoubleClicked: {
            singlemedia.doubleClicked();
        }
    }
}
