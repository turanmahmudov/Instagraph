import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: tagfeedpage

    property var tag

    header: PageHeaderItem {
        title: "#" + tag
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property var last_save_id
    property bool clear_models: true

    property bool list_loading: false

    function mediaDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id ? data.next_max_id : "";
            more_available = data.more_available ? data.more_available : false;
            next_coming = true;

            worker.sendMessage({'feed': 'tagFeedPage', 'obj': data.items, 'model': tagFeedPhotosModel, 'clear_model': clear_models})

            next_coming = false;
        }

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
        getMedia(tag);
    }

    function getMedia(tag, next_id)
    {
        if (!next_id) {
            tagFeedPhotosModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getTagFeed(tag, next_id);
    }

    ListModel {
        id: tagFeedPhotosModel
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: tagfeedpage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getMedia(tag, next_max_id);
            }
        }

        clip: true
        cacheBuffer: parent.height*2
        model: tagFeedPhotosModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            currentDelegatePage: tagfeedpage
            thismodel: tagFeedPhotosModel
        }
        PullToRefresh {
            refreshing: list_loading && tagFeedPhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getMedia(tag)
            }
        }
    }

    Connections{
        target: instagram
        onTagFeedDataReady: {
            var data = JSON.parse(answer);
            mediaDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
