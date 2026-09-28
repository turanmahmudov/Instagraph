// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// Component imports
import "../components"
import "../components/Page"
import "../components/Feed"
import "../viewmodels"

PageItem {
    id: singlephotopage

    header: PageHeaderItem {
        title: i18n.tr("Photo")
    }

    property var photoId

    SinglePhotoViewModel {
        id: feedViewModel
        photoId: singlephotopage.photoId
        onMediaNotFound: pageLayout.removePages(singlephotopage)
    }

    property alias list_loading: feedViewModel.isLoading

    Component.onCompleted: {
        feedViewModel.loadFeed();
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: singlephotopage.header.bottom
        }

        clip: true
        cacheBuffer: parent.height * 2
        model: feedViewModel.feedModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            currentPage: singlephotopage
            currentModel: feedViewModel.feedModel
            showCarousel: true
            enableVideoPlayback: true
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && feedViewModel.feedModel.count == 0
            onRefresh: {
                feedViewModel.loadFeed();
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
