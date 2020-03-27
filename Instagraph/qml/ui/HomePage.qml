import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: homepage

    header: PageHeader {
        title: i18n.tr("Instagraph")
        trailingActionBar {
            numberOfSlots: 1
            actions: [inboxAction]
        }
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property var last_save_id
    property bool clear_models: true

    property var seen_posts: []

    property bool list_loading: false

    property bool isEmpty: false

    property bool isPullToRefresh: false

    function mediaDataFinished(data) {
        isPullToRefresh = false

        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available == true ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'homePage', 'obj': data.feed_items, 'model': homePhotosModel, 'suggestionsModel': homeSuggestionsModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

            for (var i = 0; i < data.feed_items.length; i++) {
                var obj = data.feed_items[i];

                if (typeof obj.media_or_ad !== 'undefined' && typeof obj.media_or_ad.media_type !== 'undefined') {
                    seen_posts.push(obj.media_or_ad.id);
                }
            }

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {

        }
    }

    function getMedia(next_id)
    {
        clear_models = false
        if (!next_id) {
            homePhotosModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getTimeLine(next_id, seen_posts.join(','), isPullToRefresh);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: homepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: homePhotosModel
        dynamicRoles: true
    }

    ListModel {
        id: homeSuggestionsModel
    }

    ListView {
        id: homePhotosList
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
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
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && homePhotosModel.count == 0
            onRefresh: {
                list_loading = true
                isPullToRefresh = true
                getMedia()
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: homepage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        title: i18n.tr("Welcome to Instagraph!")
        description: i18n.tr("Follow accounts to see photos and videos here in your feed.")
    }

    FloatingActionButton {
        z: 1
        visible: homePhotosList.contentY > units.gu(150)
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
            bottomMargin: units.gu(7)
        }
        imageName: "go-up"
        backgroundColor: "#2B2B2B"
        onClicked: {
            homePhotosList.positionViewAtBeginning();
        }
    }

    Connections{
        target: instagram
        onTimeLineDataReady: {
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                mediaDataFinished(data);
            } else {
                // error
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
