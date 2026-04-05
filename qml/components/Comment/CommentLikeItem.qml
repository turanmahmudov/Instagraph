import QtQuick 2.12
import "../Constants"
import Lomiri.Components 1.3

import ".."

import "../../js/Helper.js" as Helper

Item {
    signal likeClicked
    signal unlikeClicked

    property bool is_liked: false

    LineIcon {
        id: commentlikeicon
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        name: is_liked ? IconsConstants.liked : IconsConstants.unliked
        color: is_liked ? LomiriColors.red : styleApp.common.iconActiveColor
        iconSize: units.gu(2.2)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (is_liked)
                unlikeClicked();
            else
                likeClicked();
        }
    }
}
