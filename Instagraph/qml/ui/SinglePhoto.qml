import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: singlephotopage

    header: PageHeaderItem {
        title: i18n.tr("Photo")
    }

    property var photoId

    property var last_like_id
    property var last_save_id

    property bool list_loading: false

    function mediaDataFinished(data) {
        if (!("items" in data) || ("items" in data && data.items.length === 0)) {
            pageLayout.removePages(singlephotopage)
        }

        worker.sendMessage({'feed': 'singlePhotoPage', 'obj': data.items, 'model': singlePhotoModel, 'clear_model': true})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/TimelineWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        instagram.getInfoMedia(photoId);
    }

    function getMedia()
    {
        singlePhotoModel.clear()
        instagram.getInfoMedia(photoId);
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
            currentDelegatePage: singlephotopage
            thismodel: singlePhotoModel
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && singlePhotoModel.count == 0
            onRefresh: {
                list_loading = true
                getMedia()
            }
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
