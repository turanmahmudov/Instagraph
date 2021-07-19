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
import QtGraphicalEffects 1.0

// Highlight/shadow shader from:
// https://github.com/BradLarson/GPUImage2/blob/master/framework/Source/Operations/Shaders/HighlightShadow_GLES.fsh

ShaderEffect {
    id: rootItem

    width: parent.width
    height: parent.height
    blending: false

    property var source
    property real value: 0.0

    // Inspired by
    // https://github.com/BradLarson/GPUImage2/blob/master/framework/Source/Operations/Shaders/UnsharpMask_GLES.fsh
    property var blurMask: ShaderEffectSource {
        width: rootItem.width
        height: rootItem.height
        visible: false
        //sourceItem: GaussianBlur {
         sourceItem: FastBlur {
            width: rootItem.width
            height: rootItem.height
            source: rootItem.source
            radius: 100//24
            visible: false
        }
    }

    //TEST
    property var brightnessContrastMap: Image {
        source: Qt.resolvedUrl("../images/brightnessContrastMap.png")
        visible: false
        sourceSize { width: 256; height: 99 }
    }

    vertexShader: "
        uniform highp mat4 qt_Matrix;
        attribute highp vec4 qt_Vertex;
        attribute highp vec2 qt_MultiTexCoord0;
        varying highp vec2 coord;
        void main () {
            coord = qt_MultiTexCoord0;
            gl_Position = (qt_Matrix * qt_Vertex);
        }
    "

    fragmentShader: "
        varying highp vec2 coord;
        uniform sampler2D source;
        uniform highp float qt_Opacity;
        uniform sampler2D blurMask;
        uniform lowp float value;

        uniform sampler2D brightnessContrastMap;

        void main() {
            lowp vec4 tex = texture2D(source, coord);
            lowp vec4 blur = texture2D(blurMask, coord);
            //lowp float intensity = 1.0 + value;

            //gl_FragColor = vec4(tex.rgb * intensity + blur.rgb * (1.0 - intensity), 1.0) * qt_Opacity;

            // TEST
            mediump vec3 result = tex.rgb * 1.6 - blur.rgb * 0.6;

            result.r = texture2D(brightnessContrastMap, vec2(result.r, 0.45)).r;
            result.g = texture2D(brightnessContrastMap, vec2(result.g, 0.45)).r;
            result.b = texture2D(brightnessContrastMap, vec2(result.b, 0.45)).r;

            result.r = texture2D(brightnessContrastMap, vec2(result.r, 0.55)).g;
            result.g = texture2D(brightnessContrastMap, vec2(result.g, 0.55)).g;
            result.b = texture2D(brightnessContrastMap, vec2(result.b, 0.55)).g;

            mediump vec3 luminanceWeighting = vec3(0.3, 0.3, 0.3);
            mediump float luminance = dot(result.rgb, luminanceWeighting);

            mediump float highlights = 1.0;

            mediump float shadow = clamp((pow(luminance, 1.0/(0.40+1.0)) + (-0.76)*pow(luminance, 2.0/(0.40+1.0))) - luminance, 0.0, 1.0);
            mediump float highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-highlights)))) - luminance, -1.0, 0.0);
            lowp vec3 sh = vec3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((result.rgb - vec3(0.0, 0.0, 0.0))/(luminance - 0.0));
            result.rgb = mix(result.rgb, sh.rgb, 0.5);

            gl_FragColor = vec4(mix(tex.rgb, result.rgb, value), 1.0) * qt_Opacity;
        }
    "
}
