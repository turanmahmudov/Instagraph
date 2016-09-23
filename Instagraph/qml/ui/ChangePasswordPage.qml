import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../components"

import "../js/Storage.js" as Storage

Page {
    id: changepasswordpage

    header: PageHeader {
        title: i18n.tr("Change Password")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    iconName: "tick"
                    text: i18n.tr("Save")
                    onTriggered: {
                        if (newPasswordField.text == newPasswordAgainField.text) {
                            instagram.changePassword(currentPasswordField.text, newPasswordField.text)
                        } else {
                            // must be same error
                        }
                    }
                }
            ]
        }
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: changepasswordpage.header.bottom
        visible: instagram.busy
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: changepasswordpage.header.bottom
        }
        contentHeight: columnSuperior.height

        Column {
           id: columnSuperior
           width: parent.width

           ListItem.Base {
               width: parent.width
               showDivider: true
               Column {
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left

                   TextField {
                       width: parent.width
                       id: currentPasswordField
                       echoMode: TextInput.Password
                       placeholderText: i18n.tr("Current password")
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
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

                   TextField {
                       width: parent.width
                       id: newPasswordField
                       echoMode: TextInput.Password
                       placeholderText: i18n.tr("New password")
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
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

                   TextField {
                       width: parent.width
                       id: newPasswordAgainField
                       echoMode: TextInput.Password
                       placeholderText: i18n.tr("New password, again")
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
                   }
               }
           }
        }
    }

    Connections{
        target: instagram
        onChangePasswordReady: {
            var data = JSON.parse(answer);
            if (data.status == 'ok') {
                pageStack.pop();
            }
        }
    }
}
