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
import ImageProcessor 1.0

Item {
    id: rootItem

    property real __imageSizeRatio: img.sourceSize.width / img.sourceSize.height
    property alias __basicFilter: basicFilterLoader.item
    property alias __filterContainer: filterContainer
    property alias __clarityFilter: clarityFilterLoader.item
    property alias __img: img
    property alias __originalImg: imgCont

    property alias imagePath: img.source

    property real brightness: 0.5
    property real contrast: 0.5
    property real temperature: 0.5
    property real saturation: 0.5
    property real vignetteOpacity: 0.0
    property real clarity: 0.5
    property real sharpen: 0.0
    property real highlights: 1.0
    property real shadows: 0.0
    property real hAxisAdjust: 0
    property real filterOpacity: 0.0

    function setDefaultSize() {
        width = Qt.binding(function() {
            return (__imageSizeRatio < 1)
                    ? __imageSizeRatio * Math.min(img.sourceSize.width, img.sourceSize.height)
                    : Math.min(img.sourceSize.width, img.sourceSize.width)
        })

        height = Qt.binding(function() {
            return (__imageSizeRatio < 1)
                    ? Math.min(img.sourceSize.width, img.sourceSize.height)
                    : Math.min(img.sourceSize.width, img.sourceSize.width) * (1 / __imageSizeRatio)
        })
    }

    function setSize(newSize) {
        width = (__imageSizeRatio < 1)
                ? __imageSizeRatio * Math.min(newSize, img.sourceSize.height)
                : Math.min(newSize, img.sourceSize.width)

        height = (__imageSizeRatio < 1)
                ? Math.min(newSize, img.sourceSize.height)
                : Math.min(newSize, img.sourceSize.width) * (1 / __imageSizeRatio)
    }

    clip: true

    onWidthChanged: console.log("[ImageContainer] Width:", width)
    onHeightChanged: console.log("[ImageContainer] Height:", height)

    Component.onCompleted: setDefaultSize()

    Item {
        id: imgCont
        anchors.fill: parent
        clip: true

        property alias img: img

        Image {
            id: img
            anchors.fill: parent
            asynchronous: true
            cache: false

            rotation: rootItem.hAxisAdjust
            scale: {
                var r = Math.abs(rotation) * 0.0174533

                if (paintedWidth > paintedHeight)
                    return (img.height + img.width * Math.sin(r) * Math.cos(r)) / img.height
                else
                    return (img.width + img.height * Math.sin(r) * Math.cos(r)) / img.width
            }
        }
    }

    Loader {
        id: basicFilterLoader
        anchors.fill: imgCont
        visible: false

        asynchronous: true
        sourceComponent: BasicFilters {
            id: basicFilter
            anchors.fill: parent

            src: ShaderEffectSource {
                width: imgCont.width
                height: imgCont.height
                sourceItem: imgCont
                visible: false
            }

            brightness: rootItem.brightness     //OK!
            contrast: rootItem.contrast         //OK!
            temperature: rootItem.temperature   // OK!
            saturation: rootItem.saturation     //OK!
            sharpen: rootItem.sharpen   // OK!
            highlights: rootItem.highlights
            shadows: rootItem.shadows
        }
    }

    Loader {
        id: clarityFilterLoader
        anchors.fill: imgCont

        asynchronous: true
        sourceComponent: ClarityFilter {
            id: clarityFilter
            anchors.fill: parent

            source: ShaderEffectSource {
                width: __basicFilter.width
                height: __basicFilter.height
                visible: false
                sourceItem: __basicFilter
            }
            value: rootItem.clarity
        }
    }

    Item {
        id: filterContainer
        anchors.fill: imgCont
        opacity: rootItem.filterOpacity
        visible: opacity > 0.0
    }

    Image {
        anchors.fill: parent
        fillMode: Image.Stretch
        source: Qt.resolvedUrl("../images/vignette.png")
        visible: rootItem.vignetteOpacity != 0
        opacity: rootItem.vignetteOpacity * 0.25
    }
}
