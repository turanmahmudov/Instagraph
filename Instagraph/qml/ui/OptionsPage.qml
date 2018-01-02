import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: optionspage

    header: PageHeader {
        title: i18n.tr("Options")
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
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem {
               height: accountHeaderLayout.height

               ListItemLayout {
                   id: accountHeaderLayout

                   title.text: i18n.tr("Account")
                   title.font.weight: Font.Normal
               }
           }

           ListItem {
               height: editProfileLayout.height
               ListItemLayout {
                   id: editProfileLayout

                   title.text: i18n.tr("Edit Profile")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("EditProfilePage.qml"))
               }
           }

           ListItem {
               height: changePasswordLayout.height
               ListItemLayout {
                   id: changePasswordLayout

                   title.text: i18n.tr("Change Password")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("ChangePasswordPage.qml"))
               }
           }

           ListItem {
               height: likedMediaLayout.height
               ListItemLayout {
                   id: likedMediaLayout

                   title.text: i18n.tr("Posts You've Liked")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("LikedMediaPage.qml"))
               }
           }

           ListItem {
               height: blockedUsersLayout.height
               ListItemLayout {
                   id: blockedUsersLayout

                   title.text: i18n.tr("Blocked Users")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("BlockedUsers.qml"))
               }
           }

           ListItem {
               height: privateAccountLayout.height
               divider.visible: false
               ListItemLayout {
                   id: privateAccountLayout

                   title.text: i18n.tr("Private Account")

                   Switch {
                       id: privateSwitch
                       SlotsLayout.position: SlotsLayout.Trailing
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
           }

           ListItem {
               height: privateAccountInfoLayout.height
               divider.visible: false
               ListItemLayout {
                   id: privateAccountInfoLayout

                   subtitle.text: i18n.tr("When your account is private, only people you approve can see your photos and videos. Your existing followers won't be affected.")
                   subtitle.maximumLineCount: 3
                   subtitle.wrapMode: Text.WordWrap
               }
           }

           ListItem {
               height: aboutHeaderLayout.height

               ListItemLayout {
                   id: aboutHeaderLayout

                   title.text: i18n.tr("About")
                   title.font.weight: Font.Normal
               }
           }

           ListItem {
               height: aboutLayout.height
               ListItemLayout {
                   id: aboutLayout

                   title.text: i18n.tr("About")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("About.qml"))
               }
           }

           ListItem {
               height: creditsLayout.height
               ListItemLayout {
                   id: creditsLayout

                   title.text: i18n.tr("Credits")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("Credits.qml"))
               }
           }

           ListItem {
               height: librariesLayout.height
               divider.visible: false
               ListItemLayout {
                   id: librariesLayout

                   title.text: i18n.tr("Libraries")
               }
               onClicked: {
                   pageStack.push(Qt.resolvedUrl("Libraries.qml"))
               }
           }

           ListItem {
               height: logOutLayout.height
               divider.visible: false
               ListItemLayout {
                   id: logOutLayout

                   title.text: i18n.tr("Log Out")
               }
               onClicked: {
                   Scripts.logOut()
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
