import QtQuick 2.12
import Ubuntu.Components 1.3

QtObject {
    property QtObject common: QtObject {
        property color iconColor: "#999999"
        property color iconActiveColor: styleApp.common.white

        property color textColor: styleApp.common.white
        property color text2Color: UbuntuColors.lightGrey
        property color linkColor: "#80C0FF"

        property color outlineButtonBorderColor: styleApp.common.white
        property color outlineButtonTextColor: styleApp.common.white
    }

    property QtObject mainView: QtObject{
        property color backgroundColor: "#030303"
    }

    property QtObject pageHeader: QtObject {
        property color backgroundColor: "#030303"
        property color dividerColor: "transparent"
    }

    property QtObject bottomMenu: QtObject {
        property color backgroundColor: "#030303"
        property color dividerColor: UbuntuColors.darkGrey
    }

    property QtObject directInbox: QtObject {
        property color incomingMessageBackgroundColor: "#030303"
        property color incomingMessageTextColor: styleApp.common.textColor

        property color outgoingMessageBackgroundColor: Qt.darker(UbuntuColors.darkGrey, 2)
        property color outgoingMessageTextColor: styleApp.common.textColor
    }
}
