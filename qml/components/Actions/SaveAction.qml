import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3

import ".."

Item {
    signal saveClicked
    signal unsaveClicked

    property bool is_saved: typeof has_viewer_saved != 'undefined' && has_viewer_saved === true

    Layout.minimumWidth: width
    Layout.preferredWidth: width

    Icon {
        id: imagesaveicon
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: units.gu(3)
        height: width
        color: styleApp.common.iconActiveColor
        source: is_saved ? "../../images/media_save.png" : "../../images/media_save_bold.png"
    }
    ColorOverlay {
        anchors.fill: imagesaveicon
        source: imagesaveicon
        color: styleApp.common.iconActiveColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (is_saved) {
                unsaveClicked();
            } else {
                saveClicked();
            }
        }
    }
}
