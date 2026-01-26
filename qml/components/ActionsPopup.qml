import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3

import "../js/Storage.js" as Storage
import "../js/Scripts.js" as Scripts
import "../js/Helper.js" as Helper

ActionSelectionPopover {
    delegate: ListItem {
        visible: action.visible
        width: parent.width
        height: action.visible ? entry_column.height + units.gu(4) : 0

        Column {
            id: entry_column
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: units.gu(2)
            }
            spacing: units.gu(1)
            width: parent.width - units.gu(4)

            Label {
                width: parent.width
                text: action.text
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
            }
        }
    }
}
