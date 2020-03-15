import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2
import QtGraphicalEffects 1.0

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

ListItem {

    property var thismodel

    property var bestImage: typeof carousel_media_obj !== 'undefined' && carousel_media_obj.count > 0 ?
                                Helper.getBestImage(carousel_media_obj.get(0).image_versions2.candidates, parent.width) :
                                Helper.getBestImage(images_obj.candidates, parent.width)

    divider.visible: false

    Item {
        width: parent.width
        height: parent.height

        FeedImage {
            id: feed_image
            width: parent.width
            height: width
            source: bestImage.url
            smooth: true
        }

        Icon {
            id: is_video_icon
            width: units.gu(3)
            height: width
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(2)
            }
            visible: false
            name: "camcorder"
            color: theme.palette.normal.baseText
        }
        DropShadow {
            anchors.fill: is_video_icon
            source: is_video_icon
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8.0
            samples: 15
            color: theme.palette.normal.base
            visible: media_type === 2
        }

        Icon {
            id: is_carousel_icon
            width: units.gu(3)
            height: width
            anchors {
                right: parent.right
                rightMargin: units.gu(2)
                top: parent.top
                topMargin: units.gu(2)
            }
            visible: false
            name: "browser-tabs"
            color: theme.palette.normal.baseText
        }
        DropShadow {
            anchors.fill: is_carousel_icon
            source: is_carousel_icon
            horizontalOffset: 2
            verticalOffset: 2
            radius: 8.0
            samples: 15
            color: theme.palette.normal.base
            visible: media_type === 8
        }
    }

    onClicked: {
        pageStack.push(Qt.resolvedUrl("../ui/SinglePhoto.qml"), {photoId: photo_id});
    }
}
