import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

ListItem {
    property var currentDelegatePage: pageLayout.primaryPage

    property var thismodel

    divider.visible: false

    MediaItem {
        width: parent.width
        height: parent.height
    }

    onClicked: {
        pageLayout.pushToNext(currentDelegatePage, Qt.resolvedUrl("../ui/SinglePhoto.qml"), {photoId: photo_id})
    }
}
