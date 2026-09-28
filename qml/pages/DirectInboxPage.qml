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

    ListItem {
        id: requestsRow
        anchors {
            left: parent.left
            right: parent.right
            top: directinboxpage.header.bottom
        }
        height: requestsLayout.height
        divider.visible: false
        onClicked: pageLayout.pushToNext(directinboxpage, PagesConstants.message_requests)

        ListItemLayout {
            id: requestsLayout
            title.text: i18n.tr("Message requests")
            title.font.weight: Font.DemiBold

            Label {
                visible: inboxViewModel.pendingRequestsTotal > 0
                SlotsLayout.position: SlotsLayout.Trailing
                text: inboxViewModel.pendingRequestsTotal
                color: styleApp.common.primaryButtonColor
                font.weight: Font.DemiBold
            }
        }
    }

    ListView {
        id: directInboxList
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: requestsRow.bottom
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
            currentPage: directinboxpage
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
            top: requestsRow.bottom
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
