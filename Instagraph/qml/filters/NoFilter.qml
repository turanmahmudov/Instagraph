import QtQuick 2.4
import "../components"

FilterBase {
    id: rootItem

    ShaderEffectSource {
        anchors.fill: parent
        sourceItem: rootItem.img
    }
}
