import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

import "../../js/Helper.js" as Helper

ListItem {
    height: layout.height
    divider.visible: false
    onClicked: {
        pageLayout.pushToNext(directinboxpage, PagesConstants.direct_thread, {threadId: thread_id})
    }

    SlotsLayout {
        id: layout

        padding.leading: 0
        padding.trailing: 0
        padding.top: units.gu(1)
        padding.bottom: units.gu(1)

        mainSlot: Row {
            id: label
            spacing: units.gu(1)
            width: parent.width - unseen_mark.width

            CircleImage {
                width: units.gu(5)
                height: width
                source: profile_pic_url
            }

            Column {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: thread_title
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    color: styleApp.common.textColor
                    width: parent.width
                }

                Text {
                    text: thread_text
                    font.weight: unseen ? Font.DemiBold : Font.ExtraLight
                    width: parent.width
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: styleApp.common.textColor
                }

                Label {
                    text: Helper.milisecondsToString(thread_time, false, true)
                    fontSize: "small"
                    color: styleApp.common.text2Color
                    font.weight: Font.Light
                    font.capitalization: Font.AllLowercase
                }
            }
        }

        Rectangle {
            id: unseen_mark
            width: unseen ? units.gu(1) : 0
            height: width
            visible: width
            radius: width/2
            color: LomiriColors.blue

            anchors.verticalCenter: parent.verticalCenter
            SlotsLayout.position: SlotsLayout.Trailing
            SlotsLayout.overrideVerticalPositioning: true
        }
    }
}
