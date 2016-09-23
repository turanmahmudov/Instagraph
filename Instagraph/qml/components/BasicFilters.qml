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
import QtGraphicalEffects 1.0

ShaderEffect {
    id: basicFilter

    property variant src

    property real brightness: 0.5
    property real contrast: 0.5
    property real temperature: 0.5
    property real saturation: 0.5
    property real sharpen: 0.0
    property real highlights: 1.0   // Range: [0.0, 1.0]
    property real shadows: 0.0      // Range [0.0, 1.0]

    blending: false

    property var sharpenSrc: ShaderEffectSource {
        width: basicFilter.width
        height: basicFilter.height
        visible: false
        sourceItem: GaussianBlur {
            width: basicFilter.width
            height: basicFilter.height
            source: basicFilter.src
            radius: 8
            samples: 16
            visible: false
        }
    }

    property var brightnessContrastMap: Image {
        source: Qt.resolvedUrl("../images/brightnessContrastMap.png")
        visible: false
        sourceSize { width: 256; height: 99 }
    }

    property var colorTemperatureMap: Image {
        source: Qt.resolvedUrl("../images/colorTemperatureMap.png")
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

    // Highlight/shadow shader from:
    // https://github.com/BradLarson/GPUImage2/blob/master/framework/Source/Operations/Shaders/HighlightShadow_GLES.fsh

    // Color temperature algorithm from:
    // https://android.googlesource.com/platform/system/media/+/8f310822ddf1205ef990d21c012eaa9530148942/mca/filterpacks/imageproc/java/ColorTemperatureFilter.java

    // Unsharp algorithm from:
    // https://github.com/BradLarson/GPUImage2/blob/master/framework/Source/Operations/Shaders/UnsharpMask_GLES.fsh

    // More details (e.g. licensing) are available in the ./tools folder.

    fragmentShader: "
        varying highp vec2 coord;
        uniform sampler2D src;
        uniform highp float qt_Opacity;
        uniform sampler2D sharpenSrc;
        uniform sampler2D brightnessContrastMap;
        uniform sampler2D colorTemperatureMap;

        uniform highp float brightness;
        uniform highp float contrast;
        uniform highp float temperature;
        uniform highp float saturation;
        uniform highp float sharpen;
        uniform highp float highlights;
        uniform highp float shadows;

        void applyBrightness(inout highp vec4 color) {
              color.r = texture2D(brightnessContrastMap, vec2(color.r, brightness)).r;
              color.g = texture2D(brightnessContrastMap, vec2(color.g, brightness)).r;
              color.b = texture2D(brightnessContrastMap, vec2(color.b, brightness)).r;
        }

        void applyContrast(inout highp vec4 color) {
            color.r = texture2D(brightnessContrastMap, vec2(color.r, contrast)).g;
            color.g = texture2D(brightnessContrastMap, vec2(color.g, contrast)).g;
            color.b = texture2D(brightnessContrastMap, vec2(color.b, contrast)).g;
        }

        // Saturation and highlights/shadow could be performed together, after a HSL conversion.
        void applySaturation(inout highp vec4 color) {
            highp vec3 intensity = vec3(dot(color.rgb, vec3(0.2125, 0.7154, 0.0721)));
            color.rgb = mix(intensity, color.rgb, saturation * 2.0);
        }

        void applyColorTemperature(inout highp vec4 color) {
            color.r = texture2D(colorTemperatureMap, vec2(color.r, temperature)).r;
            color.g = texture2D(colorTemperatureMap, vec2(color.g, temperature)).g;
            color.b = texture2D(colorTemperatureMap, vec2(color.b, temperature)).b;

            highp float maxv = max(color.r, max(color.g, color.b));
            if (maxv > 1.0) { color /= maxv; }
        }

        void applyHighlightShadow(inout highp vec4 color) {
            mediump vec3 luminanceWeighting = vec3(0.3, 0.3, 0.3);
            mediump float luminance = dot(color.rgb, luminanceWeighting);

            mediump float shadow = clamp((pow(luminance, 1.0/(shadows+1.0)) + (-0.76)*pow(luminance, 2.0/(shadows+1.0))) - luminance, 0.0, 1.0);
            mediump float highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-highlights)))) - luminance, -1.0, 0.0);
            lowp vec3 result = vec3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((color.rgb - vec3(0.0, 0.0, 0.0))/(luminance - 0.0));

            color = vec4(mix(color.rgb, result.rgb, 0.75), color.a);
        }

        void applySharpen(inout highp vec4 color) {
            highp vec4 sharp = texture2D(sharpenSrc, coord);
            color.rgb = vec3(color.rgb * (1.0 + sharpen) - sharp.rgb * sharpen);
        }

        void main() {
            lowp vec4 tex = texture2D(src, coord);

            if (sharpen != 0.0)         { applySharpen(tex);          }
            if (brightness != 0.5)      { applyBrightness(tex);       }
            if (contrast != 0.5)        { applyContrast(tex);         }
            if (saturation != 0.5)      { applySaturation(tex);       }
            if (temperature != 0.5)     { applyColorTemperature(tex); }

            if (shadows != 0.0 || highlights != 1.0) {
                applyHighlightShadow(tex);
            }

            gl_FragColor = vec4(tex.rgb, 1.0);
        }
    "
}
