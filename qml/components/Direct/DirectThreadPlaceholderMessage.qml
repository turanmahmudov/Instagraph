import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Rectangle {
    property bool isOutgoing: false
    property var itemMaxWidth

    width: placeholderColumn.width + units.gu(3)
    height: placeholderColumn.height + units.gu(2.5)
    color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
    radius: units.gu(2)
    border.width: units.gu(0.1)
    border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

    Column {
        id: placeholderColumn
        spacing: units.gu(0.4)
        anchors.centerIn: parent

        Label {
            id: placeholderText
            text: placeholder.title
            fontSize: "small"
            font.weight: Font.DemiBold
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            wrapMode: Text.WordWrap
            width: Math.min(placeholderText.implicitWidth, itemMaxWidth)
        }

        Label {
            id: placeholderMessage
            text: placeholder.message
            fontSize: "small"
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            width: Math.min(placeholderMessage.implicitWidth, itemMaxWidth)
        }
    }
}
