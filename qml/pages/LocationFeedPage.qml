import QtQuick 2.12
import QtQuick.LocalStorage 2.12

import Lomiri.Components 1.3

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

import "../components"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../viewmodels"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: locationfeedpage

    property var locationId
    property string locationName: ""

    header: PageHeaderItem {
        title: locationName
    }

    LocationFeedViewModel {
        id: feedViewModel
        locationId: locationfeedpage.locationId
    }

    property alias list_loading: feedViewModel.isLoading

    Component.onCompleted: {
        feedViewModel.loadFeed(true)
    }

    ListView {
        id: homePhotosList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: locationfeedpage.header.bottom
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
            currentPage: locationfeedpage
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
