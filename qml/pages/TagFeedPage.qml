// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../viewmodels"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: tagfeedpage

    property var tag

    header: PageHeaderItem {
        title: "#" + tag
    }

    // ViewModel handles all feed logic
    TagFeedViewModel {
        id: feedViewModel
        tag: tagfeedpage.tag
    }

    // Expose loading state for PageItem's BouncingProgressBar
    property alias list_loading: feedViewModel.isLoading

    Component.onCompleted: {
        feedViewModel.loadFeed(true)
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
        onContentYChanged: {
            if (feedViewModel.shouldLoadMore(contentY, contentHeight, height)) {
                feedViewModel.loadMore()
            }
        }

        clip: true
        cacheBuffer: parent.height*2
        model: feedViewModel.feedModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            currentPage: tagfeedpage
            currentModel: feedViewModel.feedModel
        }
        PullToRefresh {
            refreshing: list_loading && feedViewModel.feedModel.count == 0
            onRefresh: {
                feedViewModel.loadFeed(true)
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
