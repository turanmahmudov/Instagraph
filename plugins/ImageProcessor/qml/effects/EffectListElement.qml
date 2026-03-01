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
    property string prop: ""
    property string name: ""
    property string iconName: ""
    property string iconSource: ""
    property var formatValue: function(v) { return v.toFixed(0) }
    property real defaultValue: 0
    property real minimumValue: 0.0
    property real maximumValue: 1.0
}
