import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: singlephotopage

    header: PageHeader {
        title: i18n.tr("Photo")
    }

    property var photoId

    property var last_like_id

    function mediaDataFinished(data) {
        worker.sendMessage({'feed': 'singlePhotoPage', 'obj': data.items, 'model': singlePhotoModel, 'clear_model': true})
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        instagram.infoMedia(photoId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: singlephotopage.header.bottom
        visible: instagram.busy
    }

    ListModel {
        id: singlePhotoModel
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: singlephotopage.header.bottom
        }

        clip: true
        cacheBuffer: parent.height*2
        model: singlePhotoModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            thismodel: singlePhotoModel
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    Connections{
        target: instagram
        onMediaInfoReady: {
            var data = JSON.parse(answer);
            mediaDataFinished(data)
        }
    }
}
