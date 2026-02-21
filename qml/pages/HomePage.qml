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
import "../viewmodels"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: homepage

    // ViewModel handles all feed logic
    TimelineFeedViewModel {
        id: feedViewModel
    }

    // Expose loading state for PageItem's BouncingProgressBar
    property alias list_loading: feedViewModel.isLoading
    
    Component.onCompleted: {
        feedViewModel.loadFeed(true)
    }

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

    ListView {
        id: homeFeedList
        visible: !feedViewModel.isEmpty && !feedViewModel.hasError
        anchors {
            left: parent.left
            right: parent.right
            bottom: bottomMenu.top
            top: homepage.header.bottom
        }
        model: feedViewModel.feedModel
        cacheBuffer: height * 2
        clip: true
        delegate: ListFeedDelegate {
            id: homeFeedDelegate
            currentPage: homepage
            currentModel: feedViewModel.feedModel
            suggestionsModel: feedViewModel.suggestionsModel
        }
        onContentYChanged: {
            // Use ViewModel's helper to check if should load more
            if (feedViewModel.shouldLoadMore(contentY, contentHeight, height)) {
                feedViewModel.loadMore()
            }
        }
        PullToRefresh {
            refreshing: feedViewModel.isLoading && feedViewModel.feedModel.count === 0
            onRefresh: {
                feedViewModel.isPullToRefresh = true
                feedViewModel.loadFeed(true)
            }
        }
    }

    EmptyBox {
        visible: feedViewModel.isEmpty && !feedViewModel.hasError
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
        visible: feedViewModel.hasError
        width: parent.width
        anchors {
            top: homepage.header.bottom
            topMargin: units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }
        spacing: units.gu(2)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: feedViewModel.errorMessage
            fontSize: "large"
            color: styleApp.common.text2Color
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n.tr("Retry")
            color: LomiriColors.green
            onClicked: feedViewModel.loadFeed(true)
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
