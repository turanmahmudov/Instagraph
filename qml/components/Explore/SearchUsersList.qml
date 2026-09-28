import QtQuick 2.12
import Lomiri.Components 1.3

import "../Constants"
import "../User"

ListView {
    id: searchuserslist
    clip: true

    property var currentPage: pageLayout.primaryPage

    delegate: ListItem {
        width: ListView.view ? ListView.view.width : 0
        height: layout.height
        divider.visible: false
        onClicked: pageLayout.pushToCurrent(searchuserslist.currentPage, PagesConstants.user, {
            usernameId: user.pk
        })

        SlotsLayout {
            id: layout
            anchors.centerIn: parent

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
