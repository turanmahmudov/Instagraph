// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/Feed"
import "../viewmodels"

PageItem {
    id: likedmediapage

    header: PageHeaderItem {
        title: i18n.tr("Likes")
    }

    LikedMediaViewModel {
        id: feedViewModel
    }

    property alias list_loading: feedViewModel.isLoading
    property alias isEmpty: feedViewModel.isEmpty

    Component.onCompleted: {
        feedViewModel.loadFeed(true);
    }

    GridView {
        id: gridView
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: likedmediapage.header.bottom
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
            currentDelegatePage: likedmediapage
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

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: likedmediapage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        iconName: IconsConstants.image

        description: i18n.tr("No photos or videos yet!")
    }
}
