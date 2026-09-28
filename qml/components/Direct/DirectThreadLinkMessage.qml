import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

import "../Constants"
import "../../js/Helper.js" as Helper
import "../../js/Scripts.js" as Scripts

Rectangle {
    property bool isOutgoing: false
    property var itemMaxWidth

    visible: typeof link !== 'undefined' && link
    width: itemMaxWidth
    height: linkColumn.height + units.gu(2.5)
    color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
    radius: units.gu(2)
    border.width: units.gu(0.1)
    border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

    Column {
        id: linkColumn
        width: parent.width

        spacing: units.gu(1)

        Item {
            width: parent.width
            height: units.gu(0.1)
        }

        Label {
            anchors {
                left: parent.left
                leftMargin: units.gu(1.5)
                right: parent.right
                rightMargin: units.gu(1.5)
            }
            width: parent.width - units.gu(2)
            text: (link && link.text) ? Helper.makeLink(link.text) : ""
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            font.weight: Font.DemiBold
            onLinkActivated: {
                Scripts.linkClick(directthreadpage, link);
            }
        }

        Rectangle {
            width: parent.width
            height: units.gu(0.1)
            color: LomiriColors.lightGrey
        }

        Label {
            anchors {
                left: parent.left
                leftMargin: units.gu(1.5)
                right: parent.right
                rightMargin: units.gu(1.5)
            }
            width: parent.width - units.gu(2)
            text: (link && link.link_context) ? (link.link_context.link_title || "") : ""
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            wrapMode: Text.WordWrap
        }

        Label {
            anchors {
                left: parent.left
                leftMargin: units.gu(1.5)
                right: parent.right
                rightMargin: units.gu(1.5)
            }
            width: parent.width - units.gu(2)
            text: (link && link.link_context) ? (link.link_context.link_summary || "") : ""
            fontSize: "small"
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            font.weight: Font.Light
            wrapMode: Text.WordWrap
        }
    }
}
