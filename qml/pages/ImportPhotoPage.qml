// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.3

// Component imports
import "../components"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: picker

    header: PageHeaderItem {
        title: i18n.tr("Choose from")
    }

    Loader {
        anchors.fill: parent
        active: true
        visible: active
        sourceComponent: contentPickerComponent
    }

    Component {
        id: contentPickerComponent

        ContentPeerPicker {
            anchors {
                fill: parent
                top: picker.header.bottom
                topMargin: units.gu(2)
            }
            visible: parent.visible
            showTitle: false
            contentType: ContentType.Pictures
            handler: ContentHandler.Source

            onPeerSelected: {
                peer.selectionType = ContentTransfer.Single
                mainView.activeTransfer = peer.request(appStore)
                mainView.activeTransfer.stateChanged.connect(function() {
                    if (mainView.activeTransfer.state === ContentTransfer.Charged) {
                        mainView.fileImported(mainView.activeTransfer.items[0].url)
                        mainView.activeTransfer = null
                        pageLayout.removePages(picker);
                    }
                })
            }

            onCancelPressed: {
                pageLayout.removePages(picker);
            }
        }
    }

    ContentTransferHint {
        id: transferHint
        anchors.fill: parent
        activeTransfer: mainView.activeTransfer
    }
}
