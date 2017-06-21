import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem

Page {
    id: librariesPage

    header: PageHeader {
        title: i18n.tr("Libraries")
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: librariesPage.header.bottom
            topMargin: units.gu(1)
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem.Header {
               text: i18n.tr("Open Source")
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: true
               onClicked: {
                   Qt.openUrlExternally("https://github.com/mgp25/Instagram-API")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "mgp25/Instagram-API"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "Instagram's private API"
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: true
               onClicked: {
                   Qt.openUrlExternally("http://launchpad.net/instantfx")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "InstantFX"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "A photo filter application for Ubuntu Devices"
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: true
               onClicked: {
                   Qt.openUrlExternally("https://github.com/neochapay/Prostogram/")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "neochapay/Prostogram"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "An unoffical Instagram client for Sailfish"
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               progression: true
               showDivider: false
               onClicked: {
                   Qt.openUrlExternally("https://github.com/mitmproxy/mitmproxy")
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: "mitmproxy/mitmproxy"
                   }

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: "An interactive SSL-capable intercepting HTTP proxy"
                   }
               }
           }
        }
    }
}
