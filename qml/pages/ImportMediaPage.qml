// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.3

// Component imports
import "../components"
import "../components/Page"

PageItem {
    id: picker

    // ContentType.Pictures, ContentType.Videos or ContentType.All
    property int contentType: ContentType.All
    property var onPicked: null

    header: PageHeaderItem {
        title: i18n.tr("Choose from")
    }

    ContentPeerPicker {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: picker.header.bottom
            topMargin: units.gu(2)
        }
        showTitle: false
        contentType: picker.contentType
        handler: ContentHandler.Source

        onPeerSelected: {
            peer.selectionType = ContentTransfer.Single;
            mainView.activeTransfer = peer.request(appStore);
            mainView.activeTransfer.stateChanged.connect(function () {
                if (mainView.activeTransfer.state === ContentTransfer.Charged) {
                    var url = mainView.activeTransfer.items[0].url;
                    var handler = picker.onPicked;
                    mainView.activeTransfer = null;
                    pageLayout.removePages(picker);
                    if (handler) {
                        handler(url);
                    }
                }
            });
        }

        onCancelPressed: pageLayout.removePages(picker)
    }

    ContentTransferHint {
        anchors.fill: parent
        activeTransfer: mainView.activeTransfer
    }
}
