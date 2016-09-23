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

import "../components"

import ImageProcessor 1.0

ListView {
    id: filtersView
    anchors.fill: parent
    orientation: ListView.Horizontal

    highlightMoveDuration: UbuntuAnimation.SnapDuration
    preferredHighlightBegin: units.gu(12)
    preferredHighlightEnd: filtersView.width - units.gu(12)

    property ImageProcessor imageHandler

    function showLevelSettings() {
        levelSettingsLoader.active = true
    }

    delegate: AbstractButton {
        property bool isSelected: imageHandler.filterUrl == Qt.resolvedUrl("../filters/") + model.fileName

        width: units.gu(12)
        height: filtersView.height

        onClicked: {
            if (!isSelected) {
                filtersView.currentIndex = model.index
                imageHandler.filterOpacity = 1.0
                imageHandler.filterUrl = Qt.resolvedUrl("../filters/") + model.fileName
            } else {
                if (model.index != 0) {
                    filtersView.showLevelSettings()
                }
            }
        }

        Column {
            spacing: units.gu(0.5)
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(filtersView.height - units.gu(2), units.gu(10))
                height: width

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.normal.base
                }

                Image {
                    id: previewImg
                    anchors.fill: parent

                    sourceSize.width: width
                    sourceSize.height: height
                    fillMode: Image.PreserveAspectCrop

                    source: imageHandler.loadedImagePath
                    smooth: true
                    asynchronous: true
                    visible: false
                }

                Loader {
                    anchors.fill: parent
                    source: Qt.resolvedUrl("../filters/") + model.fileName
                    asynchronous: true
                    onLoaded: {
                        if (item)
                            item.img = previewImg
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.normal.background
                    opacity: 0.6
                    visible: isSelected && (model.index != 0)
                }

                Icon {
                    anchors.centerIn: parent
                    color: theme.palette.normal.backgroundText
                    width: units.gu(4); height: width
                    name: "filters"
                    visible: isSelected && (model.index != 0)
                }
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                horizontalAlignment: Text.AlignHCenter
                fontSize: "x-small"
                font.weight: Font.Bold
                font.capitalization: Font.AllUppercase
                text: model.name
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: previewImg.width
                height: units.dp(3)
                color: "#275A84"
                visible: isSelected
            }
        }
    }

    Loader {
        id: levelSettingsLoader
        parent: filtersView.parent
        anchors.fill: parent
        active: false

        sourceComponent: MouseArea {
            id: mainRect
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: theme.palette.normal.background
            }

            PageHeader {
                parent: filtersView.parent.parent
                anchors.bottom: parent.bottom
                width: parent.width

                Row {
                    anchors.fill: parent

                    AbstractButton {
                        id: button1
                        width: parent.width * 0.5
                        height: parent.height
                        onClicked: {
                            imageHandler.filterOpacity = 1.0

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

            Slider {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: units.gu(2)
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width - units.gu(8)

                minimumValue: 0.0
                maximumValue: 1.0
                live: true

                function formatValue(v) { return (v * 100).toFixed(0) }

                value: imageHandler.filterOpacity
                onValueChanged: imageHandler.filterOpacity = value

                style: SliderStyle {}
            }
        }
    }
}
