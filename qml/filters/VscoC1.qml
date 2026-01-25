import QtQuick 2.12
import QtGraphicalEffects 1.0
import "effects"
import "../components"

// Porting from CSSgram:
// https://github.com/una/CSSgram
// CSSgram license:
/*
The MIT License (MIT)

Copyright (c) 2015 Una Kravets

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

FilterBase {
    WebkitCssFilter {
        id: bc
        anchors.fill: parent
        source: img
        grayscale: 0.6
        contrast: 1.3

        visible: false
    }

    LinearGradient {
        id: ov
        visible: false
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 1.0; color: "#d5aeae" }
            GradientStop { position: 1.1; color: "#8f8f8f" }
            GradientStop { position: 1.0; color: "#c99d93" }
            GradientStop { position: 1.1; color: "#185d62" }
        }
    }

    Blend {
        id: b1
        anchors.fill: parent
        source: bc
        foregroundSource: ov
        mode: "hardLight"
    }

    Rectangle {
        id: rect2
        anchors.fill: parent
        visible: false
        color: "#58747b"
    }

    Blend {
        id: b2
        anchors.fill: parent
        source: b1
        foregroundSource: rect2
        mode: "hardLight"
    }
}
