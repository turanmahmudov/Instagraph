import QtQuick 2.12
import Ubuntu.Components 1.3

import "../fonts/"

Text {
    id: lineIcon

    property alias name: lineIcon.text

    property var iconSize: units.gu(2.4)

    property bool active: true

    font.family: Fonts.icons

    font.weight: Font.Normal

    font.pointSize: iconSize <= 0 ? 0.1 : iconSize

    color: active ? styleApp.common.iconActiveColor : styleApp.common.iconColor

    visible: iconSize <= 0 ? false : true
}
