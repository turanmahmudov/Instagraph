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
import ImageProcessor 1.0

Item {
    id: rootItem

    property ImageProcessor imageProcessor

    ShaderEffectSource {
        sourceItem: mouseArea.pressed ? rootItem.imageProcessor.__originalImageOutput : rootItem.imageProcessor.__output

        property real __imageSizeRatio: sourceItem.width / sourceItem.height
        property real __rootSizeRatio: rootItem.width / rootItem.height

        anchors.centerIn: parent
        rotation: sourceItem.rotation
        scale: sourceItem.scale

        width: (__rootSizeRatio > __imageSizeRatio)
               ? sourceItem.width * rootItem.height / sourceItem.height
               : rootItem.width

        height: (__rootSizeRatio > __imageSizeRatio)
                ? rootItem.height
                : sourceItem.height * rootItem.width / sourceItem.width
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}
