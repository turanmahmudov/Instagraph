import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3

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

    Component {
        id: popoverComponent

        Popover {
            id: popoverElement

            Column {
                width: parent.width

                ListItem {
                    height: opensourceHeaderLayout.height

                    ListItemLayout {
                        id: opensourceHeaderLayout

                        title.text: i18n.tr("Set a Profile Photo")
                        title.font.weight: Font.Normal
                    }
                }

                ListItem {
                    height: src1Layout.height
                    ListItemLayout {
                        id: src1Layout

                        title.text: i18n.tr("New Profile Photo")
                    }
                    onClicked: {
                        changePhotoClicked()
                    }
                }

                ListItem {
                    height: src2Layout.height
                    ListItemLayout {
                        id: src2Layout

                        title.text: i18n.tr("Remove Profile Photo")
                    }
                    onClicked: {
                        instagram.removeProfilePicture()
                    }
                }
            }

            Connections {
                target: instagram
                onProfilePictureChanged: {
                    PopupUtils.close(popoverElement);
                    pageStack.clear();
                    pageStack.push(tabs);
                    tabs.selectedTabIndex = 3

                    userPage.getUsernameInfo();
                }
                onProfilePictureDeleted: {
                    PopupUtils.close(popoverElement);
                    pageStack.clear();
                    pageStack.push(tabs);
                    tabs.selectedTabIndex = 3

                    userPage.getUsernameInfo();
                }
            }
        }
    }

    function profileDataFinished(data) {
        nameField.text = data.user.full_name;
        webField.text = data.user.external_url;
        bioField.text = data.user.biography;
        phoneField.text = data.user.phone_number;
        emailField.text = data.user.email;
        genderField.selectedIndex = data.user.gender;
        profilePhoto.source = data.user.profile_pic_url;
    }

    function changePhotoClicked() {
        var importPage = pageStack.push(Qt.resolvedUrl("ImportPhotoPage.qml"))

        importPage.imported.connect(function(fileUrl) {
            var pth = String(fileUrl).replace('file://', '')
            instagram.changeProfilePicture(pth)
            pageStack.pop()
        })
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

           ListItem {
               height: changeProfilePictureLayout.height
               divider.visible: false

               SlotsLayout {
                   id: changeProfilePictureLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       CircleImage {
                           id: profilePhoto
                           width: units.gu(12)
                           height: width
                           source: "../images/not_found_user.jpg"
                           anchors.horizontalCenter: parent.horizontalCenter

                           MouseArea {
                               anchors.fill: parent
                               onClicked: changePhotoClicked()
                           }
                       }

                       Label {
                           text: i18n.tr("Change Photo")
                           font.weight: Font.Normal
                           color: UbuntuColors.blue
                           anchors.horizontalCenter: parent.horizontalCenter

                           MouseArea {
                               anchors.fill: parent
                               onClicked: {
                                   PopupUtils.open(popoverComponent)
                               }
                           }
                       }
                   }
               }
           }

           ListItem {
               height: nameLayout.height

               SlotsLayout {
                   id: nameLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Name")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: nameField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           placeholderText: i18n.tr("Name")
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: webLayout.height

               SlotsLayout {
                   id: webLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Website")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: webField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           placeholderText: i18n.tr("Website")
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: bioLayout.height
               divider.visible: false

               SlotsLayout {
                   id: bioLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Bio")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextArea {
                           id: bioField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           placeholderText: i18n.tr("Bio")
                           autoSize: true
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: privateHeaderLayout.height

               ListItemLayout {
                   id: privateHeaderLayout

                   title.text: i18n.tr("Private Information")
                   title.font.weight: Font.Normal
               }
           }

           ListItem {
               height: emailLayout.height

               SlotsLayout {
                   id: emailLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Email")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: emailField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           placeholderText: i18n.tr("Email")
                           inputMethodHints: Qt.ImhEmailCharactersOnly
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: phoneLayout.height

               SlotsLayout {
                   id: phoneLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Phone")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       TextField {
                           id: phoneField
                           width: parent.width + units.gu(2)
                           anchors.horizontalCenter: parent.horizontalCenter
                           placeholderText: i18n.tr("Phone")
                           StyleHints {
                               borderColor: "transparent"
                           }
                       }
                   }
               }
           }

           ListItem {
               height: genderLayout.height

               SlotsLayout {
                   id: genderLayout
                   anchors.centerIn: parent

                   padding.leading: 0
                   padding.trailing: 0

                   mainSlot: Column {
                       width: parent.width
                       spacing: units.gu(1)

                       Label {
                           text: i18n.tr("Gender")
                           font.weight: Font.Normal
                           width: parent.width
                       }

                       OptionSelector {
                           id: genderField
                           width: parent.width
                           model: [i18n.tr("Female"),
                               i18n.tr("Male")]
                       }
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
