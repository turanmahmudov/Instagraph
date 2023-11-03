import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../fonts/"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Rectangle {
    id: bottomMenu
    z: 100000
    width: parent.width
    height: units.gu(6)
    color: styleApp.bottomMenu.backgroundColor
    anchors {
        bottom: parent.bottom
    }

    Rectangle {
        width: parent.width
        height: units.gu(0.1)
        color: styleApp.bottomMenu.dividerColor
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

            LineIcon {
                anchors.centerIn: parent
                name: "\ueae7"
                active: pageLayout.primaryPage == homePage
                iconSize: units.gu(2.4)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.removePages(homePage)
                    pageLayout.primaryPage = homePage
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            LineIcon {
                anchors.centerIn: parent
                name: "\ueb7b"
                active: pageLayout.primaryPage == exploreFeedPage
                iconSize: units.gu(2.4)
                font.weight: Font.DemiBold
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.removePages(exploreFeedPage)
                    pageLayout.primaryPage = exploreFeedPage

                    exploreFeedPage.mode = "exploreFeed"
                    exploreFeedPage.current_search_section = 0
                    exploreFeedPage.resetSearch()

                    if (exploreFeedPage.firstOpen) {
                        exploreFeedPage.getExploreFeed()
                        exploreFeedPage.firstOpen = false
                    }
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            LineIcon {
                anchors.centerIn: parent
                name: "\ueb53"
                color: styleApp.common.iconColor
                iconSize: units.gu(2.4)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.addPageToCurrentColumn(pageLayout.primaryPage, Qt.resolvedUrl("../ui/CameraPage.qml"))
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            LineIcon {
                anchors.centerIn: parent
                name: pageLayout.primaryPage == activityPage ? "\ueadf" : "\ueae1"
                active: pageLayout.primaryPage == activityPage
                iconSize: units.gu(2.4)
            }

            Rectangle {
                visible: activityPage.new_notifs
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: units.gu(0.8)
                height: width
                radius: width/2
                color: LomiriColors.orange
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.removePages(activityPage)
                    pageLayout.primaryPage = activityPage

                    activityPage.new_notifs = false
                }
            }
        }

        Item {
            width: parent.width/5
            height: parent.height

            CircleImage {
                anchors.centerIn: parent
                width: units.gu(3.2)
                height: width
                source: activeUserProfilePic != "" ? activeUserProfilePic : "../images/not_found_user.jpg"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (loggedIn) {
                        pageLayout.removePages(userPage)
                        pageLayout.primaryPage = userPage

                        userPage.getUsernameInfo();
                        userPage.getUsernameFeed();
                    }
                }
            }
        }
    }
}
