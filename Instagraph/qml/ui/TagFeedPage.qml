import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: tagfeedpage

    property var tag

    header: PageHeader {
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

            worker.sendMessage({'feed': 'tagFeedPage', 'obj': data.items, 'model': tagFeedPhotosModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
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
        instagram.tagFeed(tag, next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: tagfeedpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: tagFeedPhotosModel
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
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
