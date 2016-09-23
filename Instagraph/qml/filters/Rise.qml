import QtQuick 2.4
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
        visible: false
        sepia: 0.2
        brightness: 1.05
        contrast: 0.9
        saturate: 0.9
    }

    RadialGradient {
        id: g1
        visible: false
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#80E8C598" }
            GradientStop { position: 0.9; color: "transparent" }
        }
    }

    Blend {
        id: b1
        anchors.fill: parent
        source: g1
        foregroundSource: bc
        mode: "hardlight"   // Inverse of overlay
        visible: false
    }

    RadialGradient {
        id: g2
        visible: false
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.55; color: "#26ECCDA9" }
            GradientStop { position: 1.0; color: "#66321E07" }
        }
    }

    Blend {
        id: b2
        anchors.fill: parent
        source: b1
        foregroundSource: g2
        mode: "multiply"
    }
}
