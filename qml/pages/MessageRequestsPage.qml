// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/Direct"
import "../viewmodels"

PageItem {
    id: messagerequestspage

    header: PageHeaderItem {
        title: i18n.tr("Message requests")
    }

    MessageRequestsViewModel {
        id: requestsViewModel
    }

    property alias list_loading: requestsViewModel.isLoading

    ListView {
        id: requestsList
        visible: !requestsViewModel.isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: messagerequestspage.header.bottom
        }
        clip: true
        model: requestsViewModel.feedModel
        delegate: InboxThreadItem {
            width: ListView.view ? ListView.view.width : 0
            currentPage: messagerequestspage
        }

        PullToRefresh {
            refreshing: requestsViewModel.isLoading && requestsViewModel.feedModel.count === 0
            onRefresh: requestsViewModel.loadFeed()
        }
    }

    EmptyBox {
        visible: requestsViewModel.isEmpty
        width: parent.width
        anchors {
            top: messagerequestspage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        iconName: IconsConstants.envelope
        title: i18n.tr("No message requests")
        description: i18n.tr("Messages from people you don't follow appear here.")
    }

    Component.onCompleted: {
        requestsViewModel.loadFeed();
    }
}
