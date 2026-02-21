// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import QtQml.Models 2.12
import QtGraphicalEffects 1.0

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Components.Styles 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

// Qt imports

// Lomiri imports

// JavaScript imports

// Component imports

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
                source: "qrc:/assets/instagraph_title.png"
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
                iconName: IconsConstants.inbox
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.direct_inbox)
                }
            }
        ]
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool list_loading: false
    property bool clear_models: true

    property var seen_posts: []

    property bool isEmpty: false
    property bool isPullToRefresh: true

    ListModel {
        id: homeFeedModel
    }

    ListModel {
        id: homeSuggestionsModel
    }

    ListView {
        id: homeFeedList
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: homepage.header.bottom
        }
        model: homeFeedModel
        delegate: ListFeedDelegate {
            id: homeFeedDelegate
            currentPage: homepage
            currentModel: homeFeedModel
            suggestionsModel: homeSuggestionsModel
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) getHomeFeed(next_max_id)
        }
        PullToRefresh {
            refreshing: list_loading && homeFeedModel.count === 0
            onRefresh: {
                isPullToRefresh = true
                getHomeFeed()
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

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/HomeFeedWorker.js"
        onMessage: {
            if (messageObject.type === "seen_posts") {
                seen_posts.push(messageObject.id)
            } else if (messageObject.type === "pause") {
                more_available = false
            }
        }
    }

    Connections{
        target: instagram
        onTimelineFeedDataReady: {
            var data = JSON.parse(answer);
            homeFeedCompleted(data);
        }
    }

    function getHomeFeed(next_id) {
        list_loading = true

        clear_models = false
        if (!next_id) {
            homeFeedModel.clear()
            next_max_id = ""
            clear_models = true
        }

        instagram.getTimelineFeed(next_id, seen_posts.join(','), isPullToRefresh);
    }

    function homeFeedCompleted(data) {
        if (!data) return

        isPullToRefresh = false
        list_loading = false
        
        isEmpty = false
        if (data.num_results === 0) {
            isEmpty = true
            return
        }

        if (next_max_id === data.next_max_id) return

        next_max_id = ""
        if (data.more_available === true) {
            next_max_id = data.next_max_id
        }

        more_available = data.more_available
        next_coming = true

        worker.sendMessage(
            {
                feed_items: data.feed_items,
                feed_model: homeFeedModel,
                suggestions_model: homeSuggestionsModel,
                clear: clear_models
            }
        )
        
        next_coming = false
    }
}
