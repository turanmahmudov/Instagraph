import QtQuick 2.12
import Lomiri.Components 1.3
import Lomiri.Components.Styles 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import QtQml.Models 2.12
import QtGraphicalEffects 1.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: homepage

    header: PageHeaderItem {
        noBackAction: true
        contents: Rectangle {
            anchors.fill: parent
            color: styleApp.pageHeader.backgroundColor
            Image {
                id: logo
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                width: units.gu(12)
                height: units.gu(4)
                sourceSize: Qt.size(width,height)
                source: Qt.resolvedUrl("../../instagraph_title.png")
                smooth: true
                cache: true
            }
            ColorOverlay {
                anchors.fill: logo
                source: logo
                color: styleApp.common.textColor
            }
        }
        trailingActions: [
            Action {
                id: inboxAction
                text: i18n.tr("Inbox")
                iconName: "\ueaec"
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, Qt.resolvedUrl("DirectInboxPage.qml"))
                }
            }
        ]
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

    property bool isPullToRefresh: true

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

            worker.sendMessage({'obj': data.feed_items, 'model': homePhotosModel, 'suggestionsModel': homeSuggestionsModel, 'clear_model': clear_models})

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
        source: "../js/HomeWorker.js"
        onMessage: {

        }
    }

    function getTimelineFeed(next_id)
    {
        clear_models = false
        if (!next_id) {
            homePhotosModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getTimelineFeed(next_id, seen_posts.join(','), isPullToRefresh);
    }

    ListModel {
        id: homePhotosModel
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
                getTimelineFeed(next_max_id);
            }
        }

        model: homePhotosModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            currentDelegatePage: homepage
            thismodel: homePhotosModel
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && homePhotosModel.count == 0
            onRefresh: {
                list_loading = true
                isPullToRefresh = true
                getTimelineFeed()
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

    Connections{
        target: instagram
        onTimelineFeedDataReady: {
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
