import QtQuick 2.12
import "../Constants"
import ".."
import "../Media"
import Lomiri.Components 1.3

ListItem {
    property var currentDelegatePage: pageLayout.primaryPage

    property var thismodel

    divider.visible: false

    MediaItem {
        width: parent.width
        height: parent.height
    }

    onClicked: {
        pageLayout.pushToNext(currentDelegatePage, PagesConstants.photo, {
            photoId: photo_id
        });
    }
}
