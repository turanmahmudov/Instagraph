import QtQuick 2.12
import Lomiri.Components 1.3

import ".."
import "../Constants"
import "../User"

ListView {
    id: recentsearcheslist
    clip: true

    property var currentPage: pageLayout.primaryPage

    signal keywordClicked(string name)

    delegate: ListItem {
        width: parent.width
        height: layout.height
        divider.visible: false
        onClicked: {
            if (search_type === "user") {
                pageLayout.pushToCurrent(recentsearcheslist.currentPage, PagesConstants.user, {
                    usernameId: user.pk
                });
            } else {
                recentsearcheslist.keywordClicked(name);
            }
        }

        SlotsLayout {
            id: layout
            anchors.centerIn: parent

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
                        name: ""
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
