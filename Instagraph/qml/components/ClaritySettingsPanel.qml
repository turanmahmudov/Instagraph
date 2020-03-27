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

import QtQuick 2.4
import Ubuntu.Components 1.3

MouseArea {
    id: claritySettingsPanel
    anchors.fill: parent

    property var proc

    Rectangle { // background
        anchors.fill: parent
        color: theme.palette.normal.background
    }

    PageHeader {
        id: topPanel
        parent: claritySettingsPanel.parent.parent
        anchors.bottom: parent.bottom
        width: parent.width

        Row {
            anchors.fill: parent

            AbstractButton {
                id: button1
                width: parent.width * 0.5
                height: parent.height
                onClicked: {
                    proc.clarity = 0.0
                    claritySettingsLoader.active = false
                }

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.highlighted.background
                    visible: button1.pressed
                }

                Icon {
                    anchors.centerIn: parent
                    height: parent.height*0.4
                    color: theme.palette.normal.baseText
                    name: "close"
                }
            }

            AbstractButton {
                id: button
                width: parent.width * 0.5
                height: parent.height
                onClicked: claritySettingsLoader.active = false

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.highlighted.background
                    visible: button.pressed
                }

                Icon {
                    anchors.centerIn: parent
                    height: parent.height*0.4
                    color: theme.palette.normal.baseText
                    name: "tick"
                }
            }
        }
    }

    Slider {
        anchors {
            bottom: parent.bottom
            bottomMargin: units.gu(2)
            horizontalCenter: parent.horizontalCenter
            centerIn: parent
            verticalCenterOffset: -units.gu(2)
        }
        width: parent.width - units.gu(8)

        minimumValue: 0.0
        maximumValue: 1.0
        live: true

        function formatValue(v) {
            return (v * 100).toFixed(0)
        }

        value: proc.clarity
        onValueChanged: proc.clarity = value
        style: SliderStyle {}
    }
}
