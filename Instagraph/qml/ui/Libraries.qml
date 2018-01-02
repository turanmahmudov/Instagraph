import QtQuick 2.4
import Ubuntu.Components 1.3

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
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem {
               height: opensourceHeaderLayout.height

               ListItemLayout {
                   id: opensourceHeaderLayout

                   title.text: i18n.tr("Open Source")
                   title.font.weight: Font.Normal
               }
           }

           ListItem {
               height: src1Layout.height
               ListItemLayout {
                   id: src1Layout

                   title.text: "mgp25/Instagram-API"
                   subtitle.text: "Instagram's private API"
               }
               onClicked: {
                   Qt.openUrlExternally("https://github.com/mgp25/Instagram-API")
               }
           }

           ListItem {
               height: src2Layout.height
               ListItemLayout {
                   id: src2Layout

                   title.text: "InstantFX"
                   subtitle.text: "A photo filter application for Ubuntu Devices"
               }
               onClicked: {
                   Qt.openUrlExternally("http://launchpad.net/instantfx")
               }
           }

           ListItem {
               height: src3Layout.height
               ListItemLayout {
                   id: src3Layout

                   title.text: "neochapay/Prostogram"
                   subtitle.text: "An unoffical Instagram client for Sailfish"
               }
               onClicked: {
                   Qt.openUrlExternally("https://github.com/neochapay/Prostogram/")
               }
           }

           ListItem {
               height: src4Layout.height
               divider.visible: false
               ListItemLayout {
                   id: src4Layout

                   title.text: "mitmproxy/mitmproxy"
                   subtitle.text: "An interactive SSL-capable intercepting HTTP proxy"
               }
               onClicked: {
                   Qt.openUrlExternally("https://github.com/mitmproxy/mitmproxy")
               }
           }
        }
    }
}
