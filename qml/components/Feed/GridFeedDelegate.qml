import QtQuick 2.12
import "../Constants"
import ".."
import "../Media"
import Lomiri.Components 1.3

Item {
    property var currentDelegatePage: pageLayout.primaryPage

    MediaItem {
        width: parent.width
        height: parent.height
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            pageLayout.pushToNext(currentDelegatePage, PagesConstants.photo, {
                photoId: photo_id
            });
        }
    }
}
