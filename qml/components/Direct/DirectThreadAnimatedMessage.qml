import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Item {
    property bool isSticker: false
    property bool isOutgoing: false
    property var mediaImage
    property var itemMaxWidth

    readonly property string remoteUrl: mediaImage ? (mediaImage.url || "") : ""
    property string localUrl: ""

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
        source: localUrl
        smooth: true
        clip: true
    }

    Image {
        anchors.fill: feed_image
        visible: feed_image.status !== AnimatedImage.Ready
        source: visible ? remoteUrl : ""
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
        asynchronous: true
    }

    Connections {
        target: mediaCache
        enabled: localUrl === ""
        function onFetched(url, fileUrl) {
            if (url === remoteUrl) {
                localUrl = fileUrl;
            }
        }
    }

    Component.onCompleted: {
        localUrl = mediaCache.fetch(remoteUrl);
        if (isOutgoing) {
            anchors.right = parent.right;
        }
    }
}
