import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: locationfeedpage

    property var locationId
    property string locationName: ""

    header: PageHeaderItem {
        title: locationName
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

            worker.sendMessage({'feed': 'locationFeedPage', 'obj': data.items, 'model': locationFeedPhotosModel, 'clear_model': clear_models})

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
        getMedia(locationId);
    }

    function getMedia(location_id, next_id)
    {
        if (!next_id) {
            locationFeedPhotosModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getLocationFeed(location_id, next_id);
    }

    ListModel {
        id: locationFeedPhotosModel
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
            top: locationfeedpage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getMedia(tag, next_max_id);
            }
        }

        clip: true
        cacheBuffer: parent.height*2
        model: locationFeedPhotosModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            currentDelegatePage: locationfeedpage
            thismodel: locationFeedPhotosModel
        }
        PullToRefresh {
            refreshing: list_loading && locationFeedPhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getMedia(locationId)
            }
        }
    }

    Connections{
        target: instagram
        onGetLocationFeedDataReady: {
            var data = JSON.parse(answer);
            mediaDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
