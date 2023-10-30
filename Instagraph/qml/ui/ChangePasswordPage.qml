import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage

PageItem {
    id: changepasswordpage

    header: PageHeaderItem {
        title: i18n.tr("Change Password")
        trailingActions: [
            Action {
                text: i18n.tr("Save")
                iconName: "\uea55"
                enabled: currentPasswordField.text.length > 0 && newPasswordField.text.length > 0 && newPasswordAgainField.text.length > 0
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

           ListItem {
               height: currentPasswordLayout.height

               SlotsLayout {
                   id: currentPasswordLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Current")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: currentPasswordField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           echoMode: TextInput.Password
                           placeholderText: i18n.tr("Current password")
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: newPasswordLayout.height

               SlotsLayout {
                   id: newPasswordLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("New")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: newPasswordField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           echoMode: TextInput.Password
                           placeholderText: i18n.tr("New password")
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: verifyLayout.height
               divider.visible: false

               SlotsLayout {
                   id: verifyLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Verify")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: newPasswordAgainField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           echoMode: TextInput.Password
                           placeholderText: i18n.tr("New password, again")
                           StyleHints {
                               borderColor: "transparent"
                           }
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
