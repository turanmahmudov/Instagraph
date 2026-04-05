import QtQuick 2.12
import Lomiri.Components 1.3

import ".."

ListItem {
    height: layout.height
    divider.visible: false

    SlotsLayout {
        id: layout
        anchors.centerIn: parent
        padding.leading: 0
        padding.trailing: 0
        padding.top: units.gu(1)
        padding.bottom: units.gu(1)

        mainSlot: Row {
            id: label
            spacing: units.gu(1)
            width: parent.width

            CircleImage {
                width: units.gu(5)
                height: width
                source: profile_pic_url
            }

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: i18n.tr("<span style='color:" + LomiriColors.red + ";'>%1</span> Follow Requests").arg(request_count)
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    textFormat: Text.RichText
                    width: parent.width
                }

                Text {
                    text: i18n.tr("Approve or ignore requests")
                    wrapMode: Text.WordWrap
                    font.weight: Font.ExtraLight
                    width: parent.width
                }
            }
        }
    }
}
