import QtQuick 2.12
import Lomiri.Components 1.3

ListItem {
    height: layout.height
    divider.visible: false

    property bool followButton: false
    property var followData: ({})

    SlotsLayout {
        id: layout
        anchors.centerIn: parent

        padding.leading: 0
        padding.trailing: 0
        padding.top: units.gu(1)
        padding.bottom: units.gu(1)

        mainSlot: UserRowSlot {
            id: label
            width: followButton ? (parent.width - followLoader.width) : (parent.width - units.gu(5))
        }

        Loader {
            id: followLoader
            visible: followButton
            active: visible
            width: visible ? item.width : 0

            anchors.verticalCenter: parent.verticalCenter
            SlotsLayout.position: SlotsLayout.Trailing
            SlotsLayout.overrideVerticalPositioning: true

            sourceComponent: FollowComponent {
                height: units.gu(3.5)
                friendship_var: followData.friendship
                userId: followData.pk
                just_icon: false
            }
        }
    }
}
