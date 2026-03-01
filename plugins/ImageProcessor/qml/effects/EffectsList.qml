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

QtObject {
    property list<QtObject> model: [
        EffectListElement {
            prop: "hAxisAdjust"
            name: i18n.tr("Adjust")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/adjust-horizon.svg")
            defaultValue: 0
            minimumValue: -25
            maximumValue: 25
            formatValue: function(v) { return ((v - parseInt(v) != 0) ? v.toFixed(1) : v) + "°" }
        },

        EffectListElement {
            prop: "brightness"
            name: i18n.tr("Brightness")
            iconName: "display-brightness-min"
            iconSource: ""
            defaultValue: 0.5
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "contrast"
            name: i18n.tr("Contrast")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/contrast.svg")
            defaultValue: 0.5
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "saturation"
            name: i18n.tr("Saturation")
            iconName: "weather-chance-of-rain"
            iconSource: ""
            defaultValue: 0.5
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "temperature"
            name: i18n.tr("Temperature")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/temperature2.svg")
            defaultValue: 0.5
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "highlights"
            name: i18n.tr("Highlights")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/highlights.svg")
            defaultValue: 1.0
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "shadows"
            name: i18n.tr("Shadows")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/shadows.svg")
            defaultValue: 0.0
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "vignetteOpacity"
            name: i18n.tr("Vignette")
            iconName: "weather-clouds-symbolic"
            iconSource: ""
            defaultValue: 0.0
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        },

        EffectListElement {
            prop: "sharpen"
            name: i18n.tr("Sharpen")
            iconName: ""
            iconSource: Qt.resolvedUrl("../images/sharpen.svg")
            defaultValue: 0.0
            minimumValue: 0.0
            maximumValue: 1.0
            formatValue: function(v) { return (v * 100).toFixed(0) }
        }
    ]
}
