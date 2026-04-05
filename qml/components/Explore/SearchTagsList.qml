import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Feed"

ListView {
    delegate: ListItem {
        width: parent.width
        height: layout.height
        divider.visible: false
        onClicked: {
            pageLayout.pushToCurrent(explorePage, PagesConstants.tag_feed, {
                tag: name
            });
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
                width: parent.width - units.gu(5)

                Item {
                    width: units.gu(5)
                    height: width

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.width: units.gu(0.1)
                        border.color: Qt.lighter(LomiriColors.lightGrey, 1.1)
                        radius: width / 2

                        LineIcon {
                            anchors.centerIn: parent
                            width: units.gu(3)
                            height: width
                            name: IconsConstants.hashtag
                        }
                    }
                }

                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "#" + name
                        wrapMode: Text.WordWrap
                        font.weight: Font.DemiBold
                        width: parent.width
                        color: styleApp.common.textColor
                    }

                    Text {
                        text: media_count + i18n.tr(" posts")
                        wrapMode: Text.WordWrap
                        width: parent.width
                        textFormat: Text.RichText
                        color: styleApp.common.textColor
                    }
                }
            }
        }
    }
}
