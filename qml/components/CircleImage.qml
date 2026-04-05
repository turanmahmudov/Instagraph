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

    // Gradient ring for unseen stories — only loaded when needed
    Loader {
        anchors.fill: parent
        active: ringState === "unseen"
        sourceComponent: Canvas {
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var centerX = width / 2;
                var centerY = height / 2;
                var r = Math.min(width, height) / 2 - units.gu(0.15);

                var gradient = ctx.createLinearGradient(0, height, width, 0);
                gradient.addColorStop(0.0, "#FCAF45");
                gradient.addColorStop(0.3, "#F77737");
                gradient.addColorStop(0.6, "#F56040");
                gradient.addColorStop(0.8, "#C13584");
                gradient.addColorStop(1.0, "#833AB4");

                ctx.beginPath();
                ctx.arc(centerX, centerY, r, 0, 2 * Math.PI);
                ctx.lineWidth = units.gu(0.25);
                ctx.strokeStyle = gradient;
                ctx.stroke();
            }
            Component.onCompleted: requestPaint()
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

    Image {
        id: image

        anchors.centerIn: parent
        width: ringState !== "none" ? parent.width - units.gu(0.9) : parent.width
        height: ringState !== "none" ? parent.height - units.gu(0.9) : parent.height
        smooth: false
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width, height)
        layer.enabled: true
        layer.effect: ShaderEffect {
            property real adjustedRadius: image.width / 2
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                void main() {
                    highp vec2 center = vec2(0.5, 0.5);
                    highp float dist = distance(qt_TexCoord0, center);
                    lowp float alpha = 1.0 - smoothstep(0.5 - 0.01, 0.5, dist);
                    gl_FragColor = texture2D(source, qt_TexCoord0) * qt_Opacity * alpha;
                }
            "
        }
    }
}
