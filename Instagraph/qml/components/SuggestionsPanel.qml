import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    property var suggestionsModel

    height: suggestions_column.height + units.gu(6)
    color: "#fbfbfb"

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
                            pageStack.push(Qt.resolvedUrl("../ui/SuggestionsPage.qml"));
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
        }
    }
}
