import QtQuick 2.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

Dialog {
    id: dialog

    property string error_text: ""
    property string error_subtitle_text: ""

    title: error_text

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: units.gu(1)

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(0.5)

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: error_subtitle_text
                width: units.gu(30)
                wrapMode: Text.WordWrap
                fontSize: "medium"
                color: "#999999"
            }
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: i18n.tr("OK")
        onClicked: {
            PopupUtils.close(dialog)
        }
    }
}
