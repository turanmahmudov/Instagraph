import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: optionspage

    header: PageHeader {
        title: i18n.tr("Options")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    function profileDataFinished(data) {
        if (data.user.is_private == true) {
            privateSwitch.checked = true
        } else {
            privateSwitch.checked = false
        }
    }

    Component.onCompleted: {
        instagram.getProfileData()
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: optionspage.header.bottom
        visible: instagram.busy
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: optionspage.header.bottom
            topMargin: units.gu(1)
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem.Header {
               text: i18n.tr("Account")
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("EditProfilePage.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Edit Profile")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("ChangePasswordPage.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Change Password")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   //pageStack.push(Qt.resolvedUrl("PostsLiked.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Posts You've Liked")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   //pageStack.push(Qt.resolvedUrl("BlockedUsers.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Blocked Users")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Private Account")
                   }
               }

               Switch {
                   id: privateSwitch
                   anchors {
                       right: parent.right
                       verticalCenter: parent.verticalCenter
                   }
                   checked: false
                   onCheckedChanged: {
                        if (checked) {
                            instagram.setPrivateAccount()
                        } else {
                            instagram.setPublicAccount()
                        }
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: false
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left

                   Label {
                       fontSize: "small"
                       color: UbuntuColors.darkGrey
                       width: parent.width
                       wrapMode: Text.WordWrap
                       elide: Text.ElideRight
                       text: i18n.tr("When your account is private, only people you approve can see your photos and videos. Your existing followers won't be affected.")
                   }
               }
           }

           ListItem.Header {
               text: i18n.tr("About")
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("About.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("About")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: true
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("Credits.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Credits")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: false
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("Libraries.qml"))
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Libraries")
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               showDivider: false
               onClicked: {
                    Scripts.logOut()
               }
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left
                   Label {
                       width: parent.width
                       wrapMode: Text.WordWrap
                       text: i18n.tr("Log Out")
                   }
               }
           }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    Connections{
        target: instagram
        onProfileDataReady: {
            var data = JSON.parse(answer);
            profileDataFinished(data);
        }
        onSetProfilePublic: {
            var data = JSON.parse(answer);
            if (data.user.is_private == true) {
                privateSwitch.checked = true
            } else {
                privateSwitch.checked = false
            }
        }
        onSetProfilePrivate: {
            var data = JSON.parse(answer);
            if (data.user.is_private == true) {
                privateSwitch.checked = true
            } else {
                privateSwitch.checked = false
            }
        }
    }
}
