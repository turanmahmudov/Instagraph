import QtQuick 2.4
import Ubuntu.Components 1.3

import "../js/Helper.js" as Helper

ListView {
    id: listViewCarousel

    property var bestImage

    snapMode: ListView.SnapOneItem
    orientation: Qt.Horizontal
    highlightMoveDuration: UbuntuAnimation.FastDuration
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightFollowsCurrentItem: true
    clip: true

    delegate: Item {
        width: listViewCarousel.width
        height: listViewCarousel.height
        clip: true

        property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

        Image {
            id: feed_image
            width: parent.width
            height:parent.height
            fillMode: Image.PreserveAspectCrop
            source: parent.bestImage.url
            sourceSize: Qt.size(width,height)
            asynchronous: true
            cache: true // maybe false
            smooth: false
        }
    }
}
