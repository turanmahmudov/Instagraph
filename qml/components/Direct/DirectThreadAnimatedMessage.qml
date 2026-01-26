import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Item {
    property bool isSticker: false
    property bool isOutgoing: false
    property var mediaImage
    property var itemMaxWidth

    width: feed_image.width
    height: feed_image.height + units.gu(2.5)

    AnimatedImage {
        property bool horizontal: parseInt(mediaImage.width) > parseInt(mediaImage.height)

        id: feed_image
        width: isSticker ? (horizontal ? (mediaImage.width*height / mediaImage.height) : units.gu(16)) : itemMaxWidth
        height: isSticker ? (horizontal ? units.gu(8) : (mediaImage.height*width / mediaImage.width)) : (width/mediaImage.width*mediaImage.height)
        source: mediaImage.url
        smooth: true
        clip: true
    }

    Component.onCompleted: {
        if (isOutgoing) {
            anchors.right = parent.right
        }
    }
}
