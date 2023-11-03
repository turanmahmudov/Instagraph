/*
 * Copyright 2016 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import Lomiri.Components 1.3
import "sliderUtils.js" as SliderUtils

// [InstantFX] Not sure which is the real bottleneck.
// Two things are for sure: we heavily use GPU when updating image parameters, which prevents
// UITK slider to be properly painted with an high number of fps.
// The other thing is that this slider (like many other UITK components) is not really optimized for performance.
// The two things are catastrophic together, so we provide this lighter version of the UITK Slider theme.
// (i.e. we have removed a few animations)

Item {
    id: sliderStyle

    property color foregroundColor: theme.palette.selected.backgroundText
    property color backgroundColor: theme.palette.normal.base

    property real thumbSpacing: units.gu(0)
    property Item bar: background
    property Item thumb: thumb

    implicitWidth: units.gu(38)
    implicitHeight: units.gu(6)

    LomiriShapeOverlay {
        id: background
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            left: parent.left
        }
        height: units.dp(2)
        backgroundColor: sliderStyle.backgroundColor
        aspect: LomiriShape.Flat
        overlayColor: sliderStyle.foregroundColor
        overlayRect: {
            var pos = (sliderStyle.thumb.x / sliderStyle.thumb.barMinusThumbWidth)

            if (typeof styledItem.centeredOverlay !== "undefined" && styledItem.centeredOverlay) {
                if (pos < 0.5) {
                    return Qt.application.layoutDirection == Qt.LeftToRight ?
                                Qt.rect(pos, 0.0, 0.5 - pos, 1.0) :
                                Qt.rect(0.5, 0.0, pos, 1.0)
                } else {
                    return Qt.application.layoutDirection == Qt.LeftToRight ?
                                Qt.rect(0.5, 0.0, pos - 0.5, 1.0) :
                                Qt.rect(0.5, 0.0, pos - 0.5, 1.0)
                }
            }

            if (typeof styledItem.rightAlignedOverlay !== "undefined" && styledItem.rightAlignedOverlay) {
                return Qt.application.layoutDirection == Qt.LeftToRight ?
                            Qt.rect(pos, 0.0, 1.0, 1.0) :
                            Qt.rect(0.0, 0.0, 1.0 - pos, 1.0)
            }

            return Qt.application.layoutDirection == Qt.LeftToRight ?
                        Qt.rect(0.0, 0.0, pos, 1.0) :
                        Qt.rect(1.0 - pos, 0.0, 1.0, 1.0)
        }
    }

    Rectangle {
        id: thumb

        anchors {
            verticalCenter: parent.verticalCenter
            topMargin: thumbSpacing
            bottomMargin: thumbSpacing
        }

        property real barMinusThumbWidth: background.width - (thumb.width + 2.0*thumbSpacing)
        property real position: thumbSpacing + SliderUtils.normalizedValue(styledItem) * barMinusThumbWidth
        x: position

        width: units.gu(1.5)
        height: units.gu(1.5)
        radius: width * 0.5
        color: sliderStyle.foregroundColor

        Rectangle {
            anchors { fill: parent; margins: units.gu(-1) }
            radius: width * 0.5
            color: thumb.color
            visible: styledItem.pressed
            opacity: 0.25
        }

        Label {
            id: label
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.bottom
                topMargin: units.gu(0.5)
            }

            text: styledItem.formatValue(SliderUtils.liveValue(styledItem))
            textSize: Label.Medium
            color: theme.palette.normal.overlayText
        }
    }
}
