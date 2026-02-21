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

PageItem {
    id: homepage

    // Constants
    readonly property real paginationThreshold: 2.0
    readonly property real dividerHeight: units.gu(0.1)

    // Feed state management
    QtObject {
        id: feedState
        property string nextMaxId: ""
        property bool moreAvailable: true
        property bool nextComing: true
        property bool isLoading: false
        property bool clearModels: true
        property var seenPosts: []
        property bool isEmpty: false
        property bool isPullToRefresh: true
        property string errorMessage: ""
        property bool hasError: false
    }

    // Expose loading state for PageItem's BouncingProgressBar
    property alias list_loading: feedState.isLoading

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

    ListModel {
        id: homeFeedModel
    }

    ListModel {
        id: homeSuggestionsModel
    }

    ListView {
        id: homeFeedList
        visible: !feedState.isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: homepage.header.bottom
        }
        model: homeFeedModel
        cacheBuffer: height * 2
        clip: true
        delegate: ListFeedDelegate {
            id: homeFeedDelegate
            currentPage: homepage
            currentModel: homeFeedModel
            suggestionsModel: homeSuggestionsModel
        }
        onContentYChanged: {
            // Start loading next page when user is N screens away from bottom
            if (contentHeight - contentY - height < height * paginationThreshold && feedState.moreAvailable && !feedState.nextComing && !feedState.isLoading && feedState.nextMaxId) {
                getHomeFeed(feedState.nextMaxId)
            }
        }
        PullToRefresh {
            refreshing: feedState.isLoading && homeFeedModel.count === 0
            onRefresh: {
                feedState.isPullToRefresh = true
                getHomeFeed()
            }
        }
    }

    EmptyBox {
        visible: feedState.isEmpty && !feedState.hasError
        width: parent.width
        anchors {
            top: homepage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        title: i18n.tr("Welcome to Instagraph!")
        description: i18n.tr("Follow accounts to see photos and videos here in your feed.")
    }

    // Error state
    Column {
        visible: feedState.hasError
        width: parent.width
        anchors {
            top: homepage.header.bottom
            topMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(2)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: feedState.errorMessage
            fontSize: "large"
            color: styleApp.common.text2Color
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Retry")
            color: LomiriColors.green
            onClicked: {
                feedState.hasError = false
                getHomeFeed()
            }
        }
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
                feedState.seenPosts.push(messageObject.id)
            } else if (messageObject.type === "pause") {
                feedState.moreAvailable = false
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
        feedState.isLoading = true
        feedState.hasError = false

        feedState.clearModels = false
        if (!next_id) {
            homeFeedModel.clear()
            feedState.nextMaxId = ""
            feedState.clearModels = true
        }

        instagram.getTimelineFeed(next_id, feedState.seenPosts.join(','), feedState.isPullToRefresh);
    }

    function homeFeedCompleted(data) {
        if (!data) {
            feedState.hasError = true
            feedState.errorMessage = i18n.tr("Failed to load feed")
            feedState.isLoading = false
            return
        }

        feedState.isPullToRefresh = false
        feedState.isLoading = false
        
        feedState.isEmpty = false
        if (data.num_results === 0) {
            feedState.isEmpty = true
            return
        }

        if (feedState.nextMaxId === data.next_max_id) return

        feedState.nextMaxId = ""
        if (data.more_available === true) {
            feedState.nextMaxId = data.next_max_id
        }

        feedState.moreAvailable = data.more_available
        feedState.nextComing = true

        worker.sendMessage(
            {
                feed_items: data.feed_items,
                feed_model: homeFeedModel,
                suggestions_model: homeSuggestionsModel,
                clear: feedState.clearModels
            }
        )
        
        feedState.nextComing = false
    }
}
