import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: aboutPage

    header: PageHeader {
        title: i18n.tr("About")
        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: donateAction
                    text: i18n.tr("Donate")
                    iconName: "like"
                    onTriggered: {
                        Qt.openUrlExternally("https://liberapay.com/turanmahmudov")
                    }
                }
            ]
        }
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

        UbuntuShape {
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
                text: "<b>Instagraph</b> " + current_version
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
                linkColor: UbuntuColors.blue
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
            linkColor: UbuntuColors.blue
            fontSize: "small"
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}
