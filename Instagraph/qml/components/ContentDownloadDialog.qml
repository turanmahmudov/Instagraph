import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3

PopupBase {
    id: downloadDialog
    anchors.fill: parent
    property var activeTransfer
    property var downloadId
    property alias contentType: peerPicker.contentType

    Rectangle {
        anchors.fill: parent
        ContentPeerPicker {
            id: peerPicker
            handler: ContentHandler.Destination
            visible: parent.visible

            onPeerSelected: {
                activeTransfer = peer.request()
                activeTransfer.downloadId = downloadDialog.downloadId
                activeTransfer.state = ContentTransfer.Downloading
                PopupUtils.close(downloadDialog)
            }

            onCancelPressed: {
                PopupUtils.close(downloadDialog)
            }
        }
    }
}
