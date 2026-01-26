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
            pageLayout.pushToCurrent(explorePage, PagesConstants.location_feed, {locationId: pk, locationName: title})
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
                        radius: width/2

                        LineIcon {
                            anchors.centerIn: parent
                            width: units.gu(3)
                            height: width
                            name: IconsConstants.location
                        }
                    }
                }

                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: title
                        wrapMode: Text.WordWrap
                        font.weight: Font.DemiBold
                        width: parent.width
                        color: styleApp.common.textColor
                    }

                    Text {
                        text: subtitle
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
