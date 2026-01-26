import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import QtGraphicalEffects 1.0

import ".."

import "../../js/Storage.js" as Storage
import "../../js/Scripts.js" as Scripts
import "../../js/Helper.js" as Helper

MediaItem {
    id: singlemedia

    signal doubleClicked()

    MouseArea {
        anchors.fill: parent

        onDoubleClicked: {
            singlemedia.doubleClicked()
        }
    }
}
