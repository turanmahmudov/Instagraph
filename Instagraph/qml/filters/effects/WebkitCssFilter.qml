import QtQuick 2.4

// fragmentShader from Webkit:
// https://github.com/WebKit/webkit/blob/master/Source/WebCore/platform/graphics/texmap/TextureMapperShaderProgram.cpp
// Webkit license:

/*
 Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies)
 Copyright (C) 2012 Igalia S.L.
 Copyright (C) 2011 Google Inc. All rights reserved.

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Library General Public
 License as published by the Free Software Foundation; either
 version 2 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Library General Public License for more details.

 You should have received a copy of the GNU Library General Public License
 along with this library; see the file COPYING.LIB.  If not, write to
 the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 Boston, MA 02110-1301, USA.
*/


Item {
    id: rootItem

    property var source

    property real grayscale: 0.0
    property real sepia: 0.0
    property real saturate: 1.0
    property int hueRotate: 0
    property real brightness: 1.0
    property real contrast: 1.0

    ShaderEffect {
        id: shaderItem

        property variant source: ShaderEffectSource {
            visible: false
            anchors.fill: parent
            sourceItem: rootItem.source
        }

        property real grayscale: rootItem.grayscale
        property real sepia: rootItem.sepia
        property real saturate: rootItem.saturate
        property int hueRotate: rootItem.hueRotate
        property real brightness: rootItem.brightness
        property real contrast: rootItem.contrast

        anchors.fill: parent

        fragmentShader: "
            varying mediump vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D source;

            uniform highp float grayscale;
            uniform highp float sepia;
            uniform highp float saturate;
            uniform highp int hueRotate;
            uniform highp float brightness;
            uniform highp float contrast;

            void applyGrayscaleFilter(inout highp vec4 color) {
                highp float amount = 1.0 - grayscale;
                color = vec4((0.2126 + 0.7874 * amount) * color.r + (0.7152 - 0.7152 * amount) * color.g + (0.0722 - 0.0722 * amount) * color.b,
                        (0.2126 - 0.2126 * amount) * color.r + (0.7152 + 0.2848 * amount) * color.g + (0.0722 - 0.0722 * amount) * color.b,
                        (0.2126 - 0.2126 * amount) * color.r + (0.7152 - 0.7152 * amount) * color.g + (0.0722 + 0.9278 * amount) * color.b,
                        color.a);
            }

            void applySepiaFilter(inout highp vec4 color) {
                highp float amount = 1.0 - sepia;
                color = vec4((0.393 + 0.607 * amount) * color.r + (0.769 - 0.769 * amount) * color.g + (0.189 - 0.189 * amount) * color.b,
                        (0.349 - 0.349 * amount) * color.r + (0.686 + 0.314 * amount) * color.g + (0.168 - 0.168 * amount) * color.b,
                        (0.272 - 0.272 * amount) * color.r + (0.534 - 0.534 * amount) * color.g + (0.131 + 0.869 * amount) * color.b,
                        color.a);
            }

            void applySaturateFilter(inout highp vec4 color) {
                color = vec4((0.213 + 0.787 * saturate) * color.r + (0.715 - 0.715 * saturate) * color.g + (0.072 - 0.072 * saturate) * color.b,
                        (0.213 - 0.213 * saturate) * color.r + (0.715 + 0.285 * saturate) * color.g + (0.072 - 0.072 * saturate) * color.b,
                        (0.213 - 0.213 * saturate) * color.r + (0.715 - 0.715 * saturate) * color.g + (0.072 + 0.928 * saturate) * color.b,
                        color.a);
            }

            void applyHueRotateFilter(inout highp vec4 color) {
                highp float pi = 3.14159265358979323846;
                highp float c = cos(float(hueRotate) * pi / 180.0);
                highp float s = sin(float(hueRotate) * pi / 180.0);
                color = vec4(color.r * (0.213 + c * 0.787 - s * 0.213) + color.g * (0.715 - c * 0.715 - s * 0.715) + color.b * (0.072 - c * 0.072 + s * 0.928),
                        color.r * (0.213 - c * 0.213 + s * 0.143) + color.g * (0.715 + c * 0.285 + s * 0.140) + color.b * (0.072 - c * 0.072 - s * 0.283),
                        color.r * (0.213 - c * 0.213 - s * 0.787) +  color.g * (0.715 - c * 0.715 + s * 0.715) + color.b * (0.072 + c * 0.928 + s * 0.072),
                        color.a);
            }

            void applyBrightnessFilter(inout highp vec4 color) {
                color = vec4(color.rgb * brightness, color.a);
            }

            highp float contrastFunc(highp float n) { return (n - 0.5) * contrast + 0.5; }
            void applyContrastFilter(inout highp vec4 color) {
                color = vec4(contrastFunc(color.r), contrastFunc(color.g), contrastFunc(color.b), color.a);
            }

            void main() {
                highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                pixelColor.rgb /= max(1.0/256.0, pixelColor.a);

                if (grayscale != 0.0) {
                    applyGrayscaleFilter(pixelColor);
                }

                if (sepia != 0.0) {
                    applySepiaFilter(pixelColor);
                }

                if (saturate != 1.0) {
                    applySaturateFilter(pixelColor);
                }

                if (hueRotate != 0) {
                    applyHueRotateFilter(pixelColor);
                }

                if (brightness != 1.0) {
                    applyBrightnessFilter(pixelColor);
                }

                if (contrast != 1.0) {
                    applyContrastFilter(pixelColor);
                }

                gl_FragColor = vec4(pixelColor.rgb * pixelColor.a, pixelColor.a) * qt_Opacity;
            }
        "
    }
}
