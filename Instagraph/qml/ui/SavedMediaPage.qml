import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: savedmediapage

    header: PageHeaderItem {
        title: i18n.tr("Saved")
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool list_loading: false

    property bool isEmpty: false

    function savedMediaDataFinished(data) {
        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'savedMediaPage', 'obj': data.items, 'model': savedMediaModel, 'clear_model': clear_models})

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
        getSavedMedia();
    }

    function getSavedMedia(next_id)
    {
        console.log('START HERE')
        clear_models = false
        if (!next_id) {
            savedMediaModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getSavedFeed(next_id);
    }

    ListModel {
        id: savedMediaModel
    }

    GridView {
        id: gridView
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: savedmediapage.header.bottom
        }
        width: parent.width
        height: parent.height
        cellWidth: gridView.width/3
        cellHeight: cellWidth
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getSavedMedia(next_max_id);
            }
        }
        model: savedMediaModel
        delegate: GridFeedDelegate {
            currentDelegatePage: savedmediapage
            width: gridView.cellWidth
            height: width
        }

        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && savedMediaModel.count == 0
            onRefresh: {
                list_loading = true
                getSavedMedia()
            }
        }
    }

    Connections{
        target: instagram
        onSavedFeedDataReady: {
            var data = JSON.parse(answer);
            savedMediaDataFinished(data);
        }
    }
}
