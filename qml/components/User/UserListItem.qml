import QtQuick 2.12
import Lomiri.Components 1.3

import ".."

ListItem {
    id: userlistitem
    divider.visible: false
    height: layout.height

    property bool show_follow: user && user.pk !== instagram.my_user_id && user.friendship

    SlotsLayout {
        id: layout
        anchors.centerIn: parent

        padding.leading: 0
        padding.trailing: 0
        padding.top: units.gu(1)
        padding.bottom: units.gu(1)

        mainSlot: UserRowSlot {
            id: user_row
            width: parent.width - (show_follow ? followLoader.width : units.gu(5))
        }

        Loader {
            id: followLoader
            visible: show_follow
            active: visible
            width: visible && item ? item.width : 0

            anchors.verticalCenter: parent.verticalCenter
            SlotsLayout.position: SlotsLayout.Trailing
            SlotsLayout.overrideVerticalPositioning: true

            sourceComponent: FollowComponent2 {
                height: units.gu(3.5)
                userId: user ? user.pk : undefined
                friendship: user ? user.friendship : null
                showLabel: false
            }
        }
    }
}
