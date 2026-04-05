import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Item {
    property bool isSticker: false
    property bool isOutgoing: false
    property var mediaImage
    property var itemMaxWidth

    visible: mediaImage !== undefined
    width: visible ? feed_image.width : 0
    height: visible ? feed_image.height + units.gu(2.5) : 0

    AnimatedImage {
        id: feed_image
        property bool horizontal: mediaImage ? (parseInt(mediaImage.width || 1) > parseInt(mediaImage.height || 1)) : false
        visible: mediaImage !== undefined
        width: {
            if (!mediaImage)
                return 0;
            return isSticker ? (horizontal ? ((mediaImage.width || 1) * height / (mediaImage.height || 1)) : units.gu(16)) : itemMaxWidth;
        }
        height: {
            if (!mediaImage)
                return 0;
            return isSticker ? (horizontal ? units.gu(8) : ((mediaImage.height || 1) * width / (mediaImage.width || 1))) : (width / (mediaImage.width || 1) * (mediaImage.height || 1));
        }
        source: mediaImage ? (mediaImage.url || "") : ""
        smooth: true
        clip: true
    }

    Component.onCompleted: {
        if (isOutgoing) {
            anchors.right = parent.right;
        }
    }
}
