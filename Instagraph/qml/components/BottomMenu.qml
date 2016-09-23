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
    color: "#2B2B2B"

    Row {
        width: parent.width
        height: parent.height
        anchors {
            verticalCenter: parent.verticalCenter
            centerIn: parent
        }

        Item {
            width: parent.width/5
            height: parent.height

            Rectangle {
                visible: tabs.selectedTabIndex == 0
                anchors.fill: parent
                color: "#1C1E20"
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "navigation-menu"
                color: "#ffffff"
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

            Rectangle {
                visible: tabs.selectedTabIndex == 1
                anchors.fill: parent
                color: "#1C1E20"
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "find"
                color: "#ffffff"
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

            Rectangle {
                anchors.fill: parent
                color: "#275A84"
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "camera-app-symbolic"
                color: "#ffffff"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (pageStack.depth == 2) {
                        pageStack.clear();
                        pageStack.push(tabs);
                    }
                    //pageStack.clear()
                    pageStack.push(Qt.resolvedUrl("../ui/CameraPage.qml"))
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            Rectangle {
                visible: tabs.selectedTabIndex == 2
                anchors.fill: parent
                color: "#1C1E20"
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "unlike"
                color: "#ffffff"
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

            Rectangle {
                visible: tabs.selectedTabIndex == 3
                anchors.fill: parent
                color: "#1C1E20"
            }

            Icon {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                name: "account"
                color: "#ffffff"
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

