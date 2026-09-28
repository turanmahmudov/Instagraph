import QtQuick 2.12
import Lomiri.Components 1.3

import "Constants"

Item {
    id: suggestionsPanel

    property var suggestionsModel
    property var currentPage: pageLayout.primaryPage

    height: suggestions_column.height + units.gu(6)

    Column {
        id: suggestions_column
        width: parent.width
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(1)
        }
        spacing: units.gu(2)

        ListItem {
            height: suggestionsHeaderRow.height
            divider.visible: false

            Row {
                id: suggestionsHeaderRow
                width: parent.width
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: i18n.tr("Suggestions for You")
                    width: parent.width - seeAllSuggestionsLink.width
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: seeAllSuggestionsLink
                    text: i18n.tr("See All")
                    color: "#275A84"
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageLayout.pushToNext(suggestionsPanel.currentPage, PagesConstants.suggestions);
                        }
                    }
                }
            }
        }

        SuggestionsSlider {
            id: suggestionsSlider
            width: parent.width
            height: units.gu(15)
            model: suggestionsModel
            currentPage: suggestionsPanel.currentPage
        }
    }
}
