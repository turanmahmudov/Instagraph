import QtQuick 2.12
import Ubuntu.Components 1.3
import Ubuntu.Components.Styles 1.3
import QtGraphicalEffects 1.0

Button {
    property var model
    property var iconSize: units.gu(2)

    property color customIconColor: styleApp.common.iconActiveColor

    id: button
    width: units.gu(5)
    action: model
    enabled: model.enabled
    style: Rectangle {
        color: "transparent"
        anchors.centerIn: parent
        implicitWidth: units.gu(6)
        implicitHeight: units.gu(6)
        opacity: button.pressed ? 0.75 : 1.0
        LineIcon {
            anchors.centerIn: parent
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
