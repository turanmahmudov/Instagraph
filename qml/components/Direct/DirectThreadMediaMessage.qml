import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Image {
    property var mediaImage
    property var itemMaxWidth
    property bool isMedia

    visible: mediaImage !== undefined
    width: itemMaxWidth
    height: {
        if (!mediaImage || !mediaImage.width || !mediaImage.height) return width
        return width / mediaImage.width * mediaImage.height
    }
    source: (isMedia && mediaImage && mediaImage.url) ? mediaImage.url : ''
    fillMode: Image.PreserveAspectCrop
    sourceSize: Qt.size(width, height)
    smooth: true
    clip: true
}
