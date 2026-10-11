import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: item

    property alias source: image.source
    property alias status: image.status

    // Story ring state: "unseen", "seen", or "none"
    // When "none" (default), no ring elements are created — keeps the component lightweight
    property string ringState: "none"

    width: image.implicitWidth
    height: image.implicitHeight

    // Default border — only shown when no ring state is active
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.1)
        radius: width / 2
        visible: ringState === "none"
    }

    // Ring for unseen stories - only loaded when needed
    Loader {
        anchors.fill: parent
        active: ringState === "unseen"
        sourceComponent: Rectangle {
            color: "transparent"
            border.width: units.gu(0.25)
            border.color: "#C13584"
            radius: width / 2
        }
    }

    // Grey ring for seen stories — only loaded when needed
    Loader {
        anchors.fill: parent
        active: ringState === "seen"
        sourceComponent: Rectangle {
            color: "transparent"
            border.width: units.gu(0.15)
            border.color: Qt.lighter(LomiriColors.lightGrey, 1.0)
            radius: width / 2
        }
    }

    Rectangle {
        anchors.fill: image
        radius: width / 2
        color: Qt.rgba(0.5, 0.5, 0.5, 0.15)
        visible: image.status !== Image.Ready
    }

    Image {
        id: image

        anchors.centerIn: parent
        width: ringState !== "none" ? parent.width - units.gu(0.9) : parent.width
        height: ringState !== "none" ? parent.height - units.gu(0.9) : parent.height
        visible: false
        smooth: false
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width, height)
    }

    ShaderEffect {
        anchors.fill: image
        visible: image.status === Image.Ready

        property variant source: image
        property size cropScale: {
            var textureRatio = image.implicitWidth / Math.max(1, image.implicitHeight);
            var itemRatio = width / Math.max(1, height);
            return textureRatio > itemRatio ? Qt.size(itemRatio / textureRatio, 1) : Qt.size(1, textureRatio / itemRatio);
        }

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            uniform highp vec2 cropScale;
            void main() {
                highp vec2 center = vec2(0.5, 0.5);
                highp float dist = distance(qt_TexCoord0, center);
                lowp float alpha = 1.0 - smoothstep(0.5 - 0.01, 0.5, dist);
                highp vec2 coord = center + (qt_TexCoord0 - center) * cropScale;
                gl_FragColor = texture2D(source, coord) * qt_Opacity * alpha;
            }
        "
    }
}
