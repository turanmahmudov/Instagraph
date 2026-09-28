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
import "../components/Actions"

PageItem {
    id: savedmediapage

    header: PageHeaderItem {
        title: i18n.tr("Saved")
    }

    // ViewModel handles all feed logic
    SavedMediaViewModel {
        id: feedViewModel
    }

    // Expose loading state and empty state
    property alias list_loading: feedViewModel.isLoading
    property alias isEmpty: feedViewModel.isEmpty

    Component.onCompleted: {
        feedViewModel.loadFeed(true);
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
        cellWidth: gridView.width / 3
        cellHeight: cellWidth
        onContentYChanged: {
            if (feedViewModel.shouldLoadMore(contentY, contentHeight, height)) {
                feedViewModel.loadMore();
            }
        }
        model: feedViewModel.feedModel
        delegate: GridFeedDelegate {
            currentDelegatePage: savedmediapage
            width: gridView.cellWidth
            height: width
        }

        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && feedViewModel.feedModel.count == 0
            onRefresh: {
                feedViewModel.loadFeed(true);
            }
        }
    }
}
