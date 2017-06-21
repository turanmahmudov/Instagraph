import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../components"

import "../js/Storage.js" as Storage

Page {
    id: editprofilepage

    header: PageHeader {
        title: i18n.tr("Edit Profile")
        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    iconName: "tick"
                    text: i18n.tr("Save")
                    onTriggered: {
                        instagram.editProfile(webField.text, (phoneField.text.replace('+', '')), nameField.text, bioField.text, emailField.text, genderField.selectedIndex == 1 ? true : false);
                    }
                }
            ]
        }
    }

    function profileDataFinished(data) {
        nameField.text = data.user.full_name;
        webField.text = data.user.external_url;
        bioField.text = data.user.biography;
        phoneField.text = data.user.phone_number;
        emailField.text = data.user.email;
        genderField.selectedIndex = data.user.gender;
    }

    Component.onCompleted: {
        instagram.getProfileData()
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: editprofilepage.header.bottom
        visible: instagram.busy
    }

    Flickable {
        id: flickable
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: editprofilepage.header.bottom
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
                       id: nameField
                       placeholderText: i18n.tr("Name")
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
                       id: webField
                       placeholderText: i18n.tr("Website")
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               height: bioColumn.height + units.gu(2)
               showDivider: true
               Column {
                   id: bioColumn
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left

                   TextArea {
                       width: parent.width
                       id: bioField
                       placeholderText: i18n.tr("Bio")
                       autoSize: true
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
                   }
               }
           }

           ListItem.Header {
               text: i18n.tr("Private Information")
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
                       id: emailField
                       inputMethodHints: Qt.ImhEmailCharactersOnly
                       placeholderText: i18n.tr("Email")
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
                       id: phoneField
                       placeholderText: i18n.tr("Phone")
                       text: ""
                       StyleHints {
                           borderColor: "#ffffff"
                       }
                   }
               }
           }

           ListItem.Base {
               width: parent.width
               height: genderColumn.height + units.gu(2)
               showDivider: false
               Column {
                   id: genderColumn
                   anchors.verticalCenter: parent.verticalCenter
                   anchors.right: parent.right
                   anchors.left: parent.left

                   ListItem.ItemSelector {
                       id: genderField
                       model: [i18n.tr("Female"),
                           i18n.tr("Male")]
                       containerHeight: itemHeight * 2
                   }
               }
           }
        }
    }

    Connections{
        target: instagram
        onProfileDataReady: {
            var data = JSON.parse(answer);
            profileDataFinished(data);
        }
        onEditDataReady: {
            var data = JSON.parse(answer);
            if (data.status == 'ok') {
                pageStack.pop();
            }
        }
    }
}
