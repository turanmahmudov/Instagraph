import QtQuick 2.12
import Lomiri.Components 1.3

QtObject {
    property QtObject common: QtObject {
        property color iconColor: "#999999"
        property color iconActiveColor: styleApp.common.black

        property color textColor: styleApp.common.black
        property color text2Color: LomiriColors.darkGrey
        property color linkColor: "#0040C0"

        property color outlineButtonBorderColor: styleApp.common.black
        property color outlineButtonTextColor: styleApp.common.black
    }

    property QtObject mainView: QtObject{
        property color backgroundColor: styleApp.common.white
    }

    property QtObject pageHeader: QtObject {
        property color backgroundColor: styleApp.common.white
        property color dividerColor: "transparent"
    }

    property QtObject bottomMenu: QtObject {
        property color backgroundColor: styleApp.common.white
        property color dividerColor: LomiriColors.lightGrey
    }

    property QtObject directInbox: QtObject {
        property color incomingMessageBackgroundColor: styleApp.common.white
        property color incomingMessageTextColor: styleApp.common.textColor

        property color outgoingMessageBackgroundColor: Qt.lighter(LomiriColors.lightGrey, 1.2)
        property color outgoingMessageTextColor: styleApp.common.textColor
    }
}
