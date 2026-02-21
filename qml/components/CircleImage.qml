import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: item

    property alias source: image.source
    property alias status: image.status

    width: image.implicitWidth
    height: image.implicitHeight

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.1)
        radius: width/2
    }

    Image {
        id: image
        anchors.fill: parent
        smooth: false
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        sourceSize: Qt.size(width,height)
        layer.enabled: true
        layer.effect: ShaderEffect {
            property real radius: image.width / 2
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                uniform lowp float radius;
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
