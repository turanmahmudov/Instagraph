import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"

PageItem {
    id: aboutPage

    header: PageHeaderItem {
        title: i18n.tr("About")
    }

    Column {
        spacing: units.gu(4)
        anchors {
            margins: units.gu(2)
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: aboutPage.header.bottom
            topMargin: units.gu(5)
        }

        LomiriShape {
            anchors.horizontalCenter: parent.horizontalCenter
            width: units.gu(16)
            height: units.gu(16)
            radius: "medium"
            source: Image {
                source: Qt.resolvedUrl("../../Instagraph.png")
            }
        }

        Column {
            width: parent.width
            spacing: units.gu(0.5)

            Label {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                text: "<b>Instagraph</b> 0.1"
                fontSize: "large"
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                width: parent.width
                text: i18n.tr("Unofficial Instagram Client")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        Column {
            width: parent.width

            Label {
                text: "(C) 2016 Turan Mahmudov"
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                fontSize: "small"
            }

            Label {
                text: "<a href=\"mailto://turan.mahmudov@gmail.com\">turan.mahmudov@gmail.com</a>"
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                linkColor: styleApp.common.linkColor
                fontSize: "small"
                onLinkActivated: Qt.openUrlExternally(link)
            }

            Label {
                text: i18n.tr("Released under the terms of the GNU GPL v3")
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                fontSize: "small"
            }
        }

        Label {
            text: i18n.tr("Source code available on %1").arg("<a href=\"https://github.com/turanmahmudov/Instagraph\">Github</a>")
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            linkColor: styleApp.common.linkColor
            fontSize: "small"
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
