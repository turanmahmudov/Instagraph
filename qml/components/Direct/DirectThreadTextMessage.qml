import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Rectangle {
    property bool isOutgoing: false
    property var itemMaxWidth

    width: myText.width + units.gu(3)
    height: myText.height + units.gu(2.5)
    color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
    radius: units.gu(2)

    Label {
        id: myText
        wrapMode: Text.WordWrap
        width: Math.min(myText.implicitWidth, itemMaxWidth)
        anchors.centerIn: parent
        text: cText
        color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
    }
}
