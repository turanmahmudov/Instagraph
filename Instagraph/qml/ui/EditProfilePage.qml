import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Components.Popups 1.3

import "../components"

import "../js/Storage.js" as Storage

PageItem {
    id: editprofilepage

    property bool changeProfilePictureLoading: false

    header: PageHeaderItem {
        title: i18n.tr("Edit Profile")
        trailingActions: [
            Action {
                iconName: "\uea55"
                text: i18n.tr("Save")
                onTriggered: {
                    instagram.editProfile(webField.text, (phoneField.text.replace('+', '')), nameField.text, bioField.text, emailField.text, genderField.selectedIndex == 1 ? true : false);
                }
            }
        ]
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
                        PopupUtils.close(popoverElement);
                    }
                }

                ListItem {
                    height: src2Layout.height
                    ListItemLayout {
                        id: src2Layout

                        title.text: i18n.tr("Remove Profile Photo")
                    }
                    onClicked: {
                        changeProfilePictureLoading = true
                        instagram.removeProfilePicture()
                        PopupUtils.close(popoverElement);
                    }
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
        pageLayout.pushToCurrent(editprofilepage, Qt.resolvedUrl("ImportPhotoPage.qml"))

        mainView.fileImported.connect(function(fileUrl) {
            changeProfilePictureLoading = true
            var pth = String(fileUrl).replace('file://', '')
            instagram.changeProfilePicture(pth)
        })
    }

    Component.onCompleted: {
        instagram.getCurrentUser()
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
                               onClicked: {
                                   if (!changeProfilePictureLoading) {
                                    PopupUtils.open(popoverComponent)
                                   }
                               }
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
                                   if (!changeProfilePictureLoading) {
                                    PopupUtils.open(popoverComponent)
                                   }
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
        onCurrentUserDataReady: {
            var data = JSON.parse(answer);
            profileDataFinished(data);
        }
        onEditDataReady: {
            var data = JSON.parse(answer);
            if (data.status == 'ok') {
                pageLayout.removePages(editprofilepage)

                userPage.getUsernameInfo();
                userPage.getUsernameFeed();
            }
        }
        onProfilePictureChanged: {
            changeProfilePictureLoading = false
            pageLayout.removePages(userPage)
            pageLayout.primaryPage = userPage

            userPage.getUsernameInfo();
            userPage.getUsernameFeed();
        }
        onProfilePictureDeleted: {
            changeProfilePictureLoading = false
            pageLayout.removePages(userPage)
            pageLayout.primaryPage = userPage

            userPage.getUsernameInfo();
            userPage.getUsernameFeed();
        }
    }
}
