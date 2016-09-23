import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Page {
    id: creditsPage

    header: PageHeader {
        title: i18n.tr("Credits")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: creditsPage.header.bottom
            topMargin: units.gu(1)
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem.Header {
               text: i18n.tr("Creator")
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: false
               onClicked: {
                   Qt.openUrlExternally("mailto:turan.mahmudov@gmail.com")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "Turan Mahmudov"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "turan.mahmudov@gmail.com"
                   }
               }
           }

           ListItem.Header {
               text: i18n.tr("Developers")
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: false
               onClicked: {
                   Qt.openUrlExternally("mailto:turan.mahmudov@gmail.com")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "Turan Mahmudov"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "turan.mahmudov@gmail.com"
                   }
               }
           }

           ListItem.Header {
               text: i18n.tr("Icons")
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: false
               onClicked: {
                   Qt.openUrlExternally("mailto:kevinfeyder@gmail.com")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "Kevin Feyder"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "kevinfeyder@gmail.com"
                   }
               }
           }

           ListItem.Header {
               text: i18n.tr("Special Thanks")
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: false
               onClicked: {
                   Qt.openUrlExternally("mailto:boyogluozan@gmail.com")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "Ozan Erdem Boyoglu"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "boyogluozan@gmail.com"
                   }
               }
           }
        }
    }
}
