import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import QtGraphicalEffects 1.0

import ".."
import "../Constants"

import "../../js/Storage.js" as Storage
import "../../js/Scripts.js" as Scripts
import "../../js/Helper.js" as Helper

MediaItem {
    id: singlemedia

    signal doubleClicked()

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
                        videoPlayer.pause()
                    } else {
                        videoPlayer.play()
                    }
                }
                onDoubleClicked: {
                    singlemedia.doubleClicked()
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
                pageLayout.pushToNext(currentPage, PagesConstants.photo, {photoId: id})
            }
            // If it's a video (media_type 2) and enableVideoPlayback is false, open SinglePhoto page
            else if (media_type === 2 && !enableVideoPlayback) {
                pageLayout.pushToNext(currentPage, PagesConstants.photo, {photoId: id})
            }
        }

        onDoubleClicked: {
            singlemedia.doubleClicked()
        }
    }
}
