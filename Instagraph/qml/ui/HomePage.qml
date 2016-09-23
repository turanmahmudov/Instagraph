import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: homepage

    header: PageHeader {
        title: i18n.tr("Instagraph")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [inboxAction]
        }
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property bool clear_models: true

    property bool list_loading: false

    function mediaDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id;
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'homePage', 'obj': data.items, 'model': homePhotosModel, 'commentsModel': homePhotosCommentsModel, 'clear_model': clear_models})

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

    function getMedia(next_id)
    {
        clear_models = false
        if (!next_id) {
            homePhotosModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getTimeLine(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: homepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: homePhotosCommentsModel
    }

    ListModel {
        id: homePhotosModel
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: bottomMenu.top
            top: homepage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getMedia(next_max_id);
            }
        }

        cacheBuffer: parent.height*2
        model: homePhotosModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            thismodel: homePhotosModel
            thiscommentsmodel: homePhotosCommentsModel
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && homePhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getMedia()
            }
        }
    }

    Connections{
        target: instagram
        onTimeLineDataReady: {
            var data = JSON.parse(answer);
            mediaDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
