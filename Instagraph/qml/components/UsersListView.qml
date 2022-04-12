import QtQuick 2.12
import Ubuntu.Components 1.3

ListView {
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        top: parent.header.bottom
    }
    clip: true
    cacheBuffer: parent.height
}
