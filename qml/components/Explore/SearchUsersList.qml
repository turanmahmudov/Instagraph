import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Feed"
import "../User"

ListView {
    delegate: ListItem {
        width: parent.width
        height: layout.height
        divider.visible: false
        onClicked: pageLayout.pushToCurrent(explorePage, page.user, {
            userId: user.pk
        })

        SlotsLayout {
            id: layout

            padding.leading: 0
            padding.trailing: 0
            padding.top: units.gu(1)
            padding.bottom: units.gu(1)

            mainSlot: UserRowSlot {
                width: parent.width
            }
        }
    }
}
