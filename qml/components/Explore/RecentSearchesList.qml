import QtQuick 2.12
import "../Constants"
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Feed"
import "../User"

ListView {
    delegate: ListItem {
        width: parent.width
        height: layout.height
        divider.visible: false
        onClicked: {
            if (search_type == "user") {
                pageLayout.pushToCurrent(explorePage, PagesConstants.user, {
                    userId: user.pk
                });
            } else {
                searchInput.text = name;
                searchKeyword(name);
            }
        }

        SlotsLayout {
            id: layout

            padding.leading: 0
            padding.trailing: 0
            padding.top: units.gu(1)
            padding.bottom: units.gu(1)

            mainSlot: Loader {
                width: parent.width
                sourceComponent: search_type === "keyword" ? keywordComponent : userComponent
            }
        }

        Component {
            id: userComponent

            UserRowSlot {
                width: parent.width
            }
        }

        Component {
            id: keywordComponent

            Row {
                width: parent.width
                spacing: units.gu(1)

                Item {
                    width: units.gu(5)
                    height: width

                    LineIcon {
                        anchors.centerIn: parent
                        name: IconsConstants.search
                    }
                }

                Column {
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: name
                        wrapMode: Text.WordWrap
                        font.weight: Font.DemiBold
                        width: parent.width
                        color: styleApp.common.textColor
                    }
                }
            }
        }
    }
}
