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
    id: directinboxpage

    header: PageHeaderItem {
        title: i18n.tr("Direct")
        trailingActions: [
            Action {
                id: newDirectMessageAction
                text: i18n.tr("New Message")
                iconName: IconsConstants.pencil
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.new_direct_message);
                }
            }
        ]
    }

    DirectInboxViewModel {
        id: inboxViewModel
    }

    property alias list_loading: inboxViewModel.isLoading
    property alias isEmpty: inboxViewModel.isEmpty

    ListView {
        id: directInboxList
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: directinboxpage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd) {
                inboxViewModel.loadMore();
            }
        }

        clip: true
        cacheBuffer: parent.height
        model: inboxViewModel.feedModel
        delegate: InboxThreadItem {
            width: ListView.view ? ListView.view.width : 0
        }

        PullToRefresh {
            refreshing: list_loading && inboxViewModel.feedModel.count == 0
            onRefresh: {
                inboxViewModel.loadFeed(true);
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: directinboxpage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        iconName: IconsConstants.envelope

        title: i18n.tr("Welcome to Instagraph Direct!")
        description: i18n.tr("Tap the + icon to send a photo, video or message.")
    }

    Component.onCompleted: {
        inboxViewModel.loadFeed(true);
    }
}
