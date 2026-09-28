import QtQuick 2.12
import Lomiri.Components 1.3
import Lomiri.Components.Styles 1.3
import QtGraphicalEffects 1.0

Button {
    id: button
    property var model
    property var iconSize: units.gu(2)

    property color customIconColor: styleApp.common.iconActiveColor
    readonly property bool themeIcon: model.iconName.length > 1 && model.iconName !== "back" && model.iconName !== "down"
    width: units.gu(5)
    color: "transparent"
    gradient: null
    font: Qt.application.font
    action: model
    enabled: model.enabled
    style: Rectangle {
        color: "transparent"
        anchors.centerIn: parent
        implicitWidth: units.gu(6)
        implicitHeight: units.gu(6)
        opacity: button.pressed ? 0.75 : 1.0
        Icon {
            anchors.centerIn: parent
            visible: themeIcon
            width: units.gu(3.25)
            height: width
            name: themeIcon ? model.iconName : ""
            color: customIconColor
        }
        LineIcon {
            anchors.centerIn: parent
            visible: !themeIcon
            name: model.iconName === "back" ? "\uea5a" : (model.iconName === "down" ? "\uea58" : model.iconName)
            iconSize: button.iconSize
            color: customIconColor
            layer.enabled: customIconColor === styleApp.common.white
            layer.effect: DropShadow {
                verticalOffset: 2
                horizontalOffset: 2
                spread: 0.4
            }
        }
    }
}
