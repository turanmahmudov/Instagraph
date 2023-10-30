/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.12
import Lomiri.Components 1.3

AbstractButton {
    id: rootItem
    width: units.gu(12)
    height: parent.height

    property bool selected
    property alias name: nameLabel.text

    Column {
        spacing: units.gu(2)
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: previewImg
            anchors.horizontalCenter: parent.horizontalCenter
            width: units.gu(8); height: width
            radius: width * 0.5

            color: rootItem.pressed ? border.color : "transparent"
            border {
                width: units.dp(0.5)
                color: Qt.rgba(theme.palette.normal.base.r, theme.palette.normal.base.g, theme.palette.normal.base.b, 0.5)
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(4); height: width
                color: theme.palette.normal.foregroundText
                source: modelData.iconName ? "image://theme/%1".arg(modelData.iconName) : modelData.iconSource
            }
        }

        Label {
            id: nameLabel
            anchors { left: parent.left; right: parent.right }
            horizontalAlignment: Text.AlignHCenter
            fontSize: "x-small"
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase

            Label {
                text: "\u2B24"
                font.pixelSize: units.gu(1)
                visible: rootItem.selected
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.bottom
                }
            }
        }
    }
}
