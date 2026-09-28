// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Actions"
import "../viewmodels"

PageItem {
    id: optionspage

    header: PageHeaderItem {
        title: i18n.tr("Options")
    }

    OptionsViewModel {
        id: optionsViewModel
    }

    Component.onCompleted: {
        optionsViewModel.loadAccount();
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
                    pageLayout.pushToCurrent(optionspage, PagesConstants.edit_profile);
                }
            }

            ListItem {
                height: changePasswordLayout.height
                ListItemLayout {
                    id: changePasswordLayout

                    title.text: i18n.tr("Change Password")
                }
                onClicked: {
                    pageLayout.pushToCurrent(optionspage, PagesConstants.change_password);
                }
            }

            ListItem {
                height: likedMediaLayout.height
                ListItemLayout {
                    id: likedMediaLayout

                    title.text: i18n.tr("Posts You've Liked")
                }
                onClicked: {
                    pageLayout.pushToCurrent(optionspage, PagesConstants.liked_media);
                }
            }

            ListItem {
                height: blockedUsersLayout.height
                ListItemLayout {
                    id: blockedUsersLayout

                    title.text: i18n.tr("Blocked Users")
                }
                onClicked: {
                    pageLayout.pushToCurrent(optionspage, PagesConstants.blocked_users);
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
                        checked: optionsViewModel.isPrivate
                        onClicked: {
                            optionsViewModel.setPrivate(checked);
                            checked = Qt.binding(function () {
                                return optionsViewModel.isPrivate;
                            });
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
                    pageLayout.pushToCurrent(optionspage, PagesConstants.about);
                }
            }

            ListItem {
                height: creditsLayout.height
                ListItemLayout {
                    id: creditsLayout

                    title.text: i18n.tr("Credits")
                }
                onClicked: {
                    pageLayout.pushToCurrent(optionspage, PagesConstants.credits);
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
                    Scripts.logOut();
                }
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
