// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.3

// Component imports
import "../components"
import "../components/Page"

PageItem {
    id: exporter

    property var fileUrls: []
    property int contentType: ContentType.Pictures

    header: PageHeaderItem {
        title: i18n.tr("Save to")
    }

    Component {
        id: exportItemComponent
        ContentItem {}
    }

    ContentPeerPicker {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: exporter.header.bottom
            topMargin: units.gu(2)
        }
        showTitle: false
        contentType: exporter.contentType
        handler: ContentHandler.Destination

        onPeerSelected: {
            var transfer = peer.request();
            transfer.items = fileUrls.map(function (fileUrl) {
                return exportItemComponent.createObject(exporter, {
                    "url": fileUrl
                });
            });
            transfer.state = ContentTransfer.Charged;
            pageLayout.removePages(exporter);
        }

        onCancelPressed: pageLayout.removePages(exporter)
    }
}
