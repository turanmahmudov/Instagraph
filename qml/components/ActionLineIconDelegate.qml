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
        Rectangle {
            readonly property int count: model.badgeCount || 0
            visible: count > 0
            z: 1
            anchors {
                horizontalCenter: parent.horizontalCenter
                horizontalCenterOffset: units.gu(1.4)
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -units.gu(1.2)
            }
            width: Math.max(height, badgeLabel.implicitWidth + units.gu(0.8))
            height: units.gu(2)
            radius: height / 2
            color: LomiriColors.red

            Label {
                id: badgeLabel
                anchors.centerIn: parent
                text: parent.count > 99 ? "99+" : parent.count
                color: "#ffffff"
                fontSize: "x-small"
                font.weight: Font.DemiBold
            }
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
