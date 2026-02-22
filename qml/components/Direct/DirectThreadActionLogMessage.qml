import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Row {
    property string userId
    property var users

    width: units.gu(5)
    height: units.gu(5)
    spacing: units.gu(0.5)

    LineIcon {
        anchors.verticalCenter: parent.verticalCenter
        name: IconsConstants.liked
        color: LomiriColors.red
        iconSize: units.gu(2.4)
    }

    CircleImage {
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(2)
        height: width
        source: {
            if (userId == activeUserId) return ''
            if (!users || !users[userId]) return ''
            return users[userId].profile_pic_url || ''
        }
    }
}
