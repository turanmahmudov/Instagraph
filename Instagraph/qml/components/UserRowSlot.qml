import QtQuick 2.12
import Ubuntu.Components 1.3

Row {
    spacing: units.gu(1)

    CircleImage {
        width: units.gu(5)
        height: width
        source: profile_pic_url
    }

    Column {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: username
            wrapMode: Text.WordWrap
            font.weight: Font.DemiBold
            width: parent.width
            color: styleApp.common.textColor
        }

        Text {
            text: full_name
            wrapMode: Text.WordWrap
            width: parent.width
            textFormat: Text.RichText
            color: styleApp.common.textColor
        }
    }
}
