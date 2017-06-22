import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Rectangle {
    id: bottomMenu
    z: 100000
    width: parent.width
    height: units.gu(6)
    anchors {
        bottom: parent.bottom
    }

    Rectangle {
        width: parent.width
        height: units.gu(0.1)
        color: UbuntuColors.lightGrey
    }

    Row {
        width: parent.width
        height: parent.height-units.gu(0.2)
        anchors {
            centerIn: parent
            bottom: parent.bottom
        }

        Item {
            width: parent.width/5
            height: parent.height

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "navigation-menu"
                color: tabs.selectedTabIndex == 0 ? "#000000" : "#999999"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.pop();
                    pageStack.push(tabs);
                    tabs.selectedTabIndex = 0
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "find"
                color: tabs.selectedTabIndex == 1 ? "#000000" : "#999999"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.pop();
                    pageStack.push(tabs);
                    tabs.selectedTabIndex = 1

                    if (searchPageOpenFirstTime) {
                        searchPage.getPopular();
                        searchPageOpenFirstTime = false
                    }
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "add"
                color: "#999999"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (pageStack.depth == 2) {
                        pageStack.clear();
                        pageStack.push(tabs);
                    }
                    pageStack.push(Qt.resolvedUrl("../ui/CameraPage.qml"))
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "unlike"
                color: tabs.selectedTabIndex == 2 ? "#000000" : "#999999"
            }

            Rectangle {
                visible: new_notifs
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: units.gu(0.8)
                height: width
                radius: width/2
                color: UbuntuColors.orange
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.pop();
                    pageStack.push(tabs);
                    tabs.selectedTabIndex = 2

                    new_notifs = false
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "account"
                color: tabs.selectedTabIndex == 3 ? "#000000" : "#999999"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (logged_in) {
                        pageStack.pop();
                        pageStack.push(tabs);
                        tabs.selectedTabIndex = 3

                        userPage.getUsernameInfo();
                        userPage.getUsernameFeed();
                    }
                }
            }
        }
    }
}

