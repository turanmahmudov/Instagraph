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
import Ubuntu.Components 1.3

PageHeader {
    id: functionSelector

    property int selectedIndex: 0
    property alias model: repeater.model

    Row {
        anchors.fill: parent

        Repeater {
            id: repeater
            model: functionSelector.iconModel

            ListItem {
                id: button
                property bool isSelected: model.index == functionSelector.selectedIndex

                width: parent.width / repeater.count
                height: parent.height

                onClicked: {
                    functionSelector.selectedIndex = model.index
                }

                Label {
                    anchors.centerIn: parent
                    text: modelData
                    //font.capitalization: Font.AllUppercase
                    font.weight: Font.DemiBold
                    //fontSize: "small"
                    color: button.isSelected ? "#000000" : UbuntuColors.darkGrey
                }

                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                    }
                    width: button.width
                    height: units.dp(2)
                    color: "#000000"
                    visible: button.isSelected
                }
            }
        }
    }
}
