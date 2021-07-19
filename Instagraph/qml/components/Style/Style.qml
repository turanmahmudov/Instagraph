import QtQuick 2.12
import Ubuntu.Components 1.3

QtObject {
    property bool dark: theme.name == 'Ubuntu.Components.Themes.SuruDark'
    property var currentStyle: dark ? styleDark : styleLight

    property QtObject common: QtObject {
        property color black: "#000000"
        property color white: "#FFFFFF"
        property color red: "#C83832"

        property color iconColor: currentStyle.common.iconColor
        property color iconActiveColor: currentStyle.common.iconActiveColor

        property color textColor: currentStyle.common.textColor
        property color text2Color: currentStyle.common.text2Color
        property color linkColor: currentStyle.common.linkColor

        property color outlineButtonBorderColor: currentStyle.common.outlineButtonBorderColor
        property color outlineButtonTextColor: currentStyle.common.outlineButtonTextColor
    }

    property QtObject mainView: currentStyle.mainView

    property QtObject pageHeader: currentStyle.pageHeader

    property QtObject bottomMenu: currentStyle.bottomMenu

    property QtObject directInbox: currentStyle.directInbox
}
