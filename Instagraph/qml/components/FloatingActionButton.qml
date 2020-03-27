import QtQuick 2.4
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

Button {
    id: button

    property string imageName: ""

    property string backgroundColor: ""

    property bool showShadow: true

    style: Rectangle {
        implicitWidth: units.gu(6)
        implicitHeight: units.gu(6)
        color: backgroundColor
        radius: width / 2
        opacity: button.pressed ? 0.75 : 1.0
        layer.enabled: button.showShadow
        layer.effect: DropShadow {
            verticalOffset: 3
            horizontalOffset: 1
            spread: 0.5
        }
        Icon {
            name: imageName
            color: theme.palette.normal.baseText
            width: units.gu(3)
            height: width
            anchors.centerIn: parent
        }
    }
}
