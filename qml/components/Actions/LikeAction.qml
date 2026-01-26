import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3

import ".."

Item {
    signal likeClicked()
    signal unlikeClicked()

    property bool is_liked: has_liked == true

    Layout.minimumWidth: width
    Layout.preferredWidth: width

    LineIcon {
        id: imagelikeicon
        anchors.verticalCenter: parent.verticalCenter
        name: is_liked ? IconsConstants.liked : IconsConstants.unliked
        color: is_liked ? LomiriColors.red : styleApp.common.iconActiveColor
        iconSize: units.gu(2.2)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (is_liked) {
                unlikeClicked()
            } else {
                likeClicked()
            }
        }
    }
}
