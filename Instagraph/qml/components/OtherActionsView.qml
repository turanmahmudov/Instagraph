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

import "../effects"

import ImageProcessor 1.0

ListView {
    id: otherActionsView
    anchors.fill: parent
    orientation: ListView.Horizontal

    property ImageProcessor imageHandler

    function showLevelSettings(data) {
        levelSettingsLoader.active = true
        levelSettingsLoader.item.modelData = data
    }

    Component.onCompleted: {
        // WORKAROUND: Fix for wrong grid unit size
        flickDeceleration = 1500 * units.gridUnit / 8
        maximumFlickVelocity = 2500 * units.gridUnit / 8
    }

    // Keep same Y-pos for the image
    delegate: OtherActionDelegate {
        id: actionDelegate
        name: modelData.name
        selected: imageHandler.getProperty(modelData.prop) != modelData.defaultValue
        onClicked: otherActionsView.showLevelSettings(modelData)

        Connections {
            target: imageHandler
            onImageSettingsChanged: actionDelegate.selected = (imageHandler.getProperty(modelData.prop) != modelData.defaultValue)
        }
    }

    Loader {
        id: levelSettingsLoader
        parent: otherActionsView.parent
        anchors.fill: parent
        active: false

        sourceComponent: MouseArea {
            id: actionSettingsContainer
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: theme.palette.normal.background
            }

            property var modelData
            onModelDataChanged: {
                sliderLoader.active = false
                sliderLoader.active = true
            }

            PageHeader {
                parent: otherActionsView.parent.parent
                anchors.bottom: parent.bottom
                width: parent.width

                Row {
                    anchors.fill: parent

                    AbstractButton {
                        id: button1
                        width: parent.width * 0.5
                        height: parent.height
                        onClicked: {
                            imageHandler.setProperty(modelData.prop, modelData.defaultValue)

                            // Close level settings
                            levelSettingsLoader.active = false
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: theme.palette.highlighted.background
                            visible: button1.pressed
                        }

                        Icon {
                            anchors.centerIn: parent
                            height: parent.height*0.4
                            color: "#000000"
                            name: "close"
                        }
                    }


                    AbstractButton {
                        id: button
                        width: parent.width * 0.5
                        height: parent.height
                        onClicked: levelSettingsLoader.active = false

                        Rectangle {
                            anchors.fill: parent
                            color: theme.palette.highlighted.background
                            visible: button.pressed
                        }

                        Icon {
                            anchors.centerIn: parent
                            height: parent.height*0.4
                            color: "#000000"
                            name: "tick"
                        }
                    }
                }
            }

            Loader {
                id: sliderLoader
                active: false
                sourceComponent: Slider {
                    parent: sliderLoader.parent
                    anchors {
                        bottom: parent.bottom
                        bottomMargin: units.gu(2)
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width - units.gu(8)

                    minimumValue: modelData.minimumValue
                    maximumValue: modelData.maximumValue
                    live: true

                    function formatValue(v) {
                        return modelData.formatValue(v)
                    }

                    value: imageHandler.getProperty(modelData.prop)
                    onValueChanged: imageHandler.setProperty(modelData.prop, value)

                    property bool centeredOverlay: modelData.defaultValue > modelData.minimumValue && modelData.defaultValue < modelData.maximumValue
                    property bool rightAlignedOverlay: modelData.defaultValue == modelData.maximumValue

                    style: SliderStyle {}
                }
            }
        }
    }
}
