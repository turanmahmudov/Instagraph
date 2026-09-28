import QtQuick 2.12
import ".."
import Lomiri.Components 1.3

QtObject {
    property QtObject common: QtObject {
        property color iconColor: "#999999"
        property color iconActiveColor: styleApp.common.white

        property color textColor: styleApp.common.white
        property color text2Color: LomiriColors.lightGrey
        property color linkColor: "#80C0FF"

        property color outlineButtonBorderColor: styleApp.common.white
        property color outlineButtonTextColor: styleApp.common.white

        property color backgroundColor: "#030303"
        property color baseBorderColor: LomiriColors.darkGrey

        property color primaryButtonColor: "#1877F2"
        property color secondaryButtonColor: "#363636"
    }

    property QtObject mainView: QtObject {
        property color backgroundColor: "#030303"
    }

    property QtObject pageHeader: QtObject {
        property color backgroundColor: "#030303"
        property color dividerColor: "transparent"
    }

    property QtObject bottomMenu: QtObject {
        property color backgroundColor: "#030303"
        property color dividerColor: LomiriColors.darkGrey
    }

    property QtObject directInbox: QtObject {
        property color incomingMessageBackgroundColor: "#262626"
        property color incomingMessageTextColor: styleApp.common.textColor

        property color outgoingMessageBackgroundColor: Qt.darker(LomiriColors.darkGrey, 2)
        property color outgoingMessageTextColor: styleApp.common.textColor

        property color outgoingTextBackgroundColor: "#1877F2"
        property color outgoingTextColor: styleApp.common.white
    }
}
