// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.1

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
import "../components/Camera"
import "../components/Actions"
import "../viewmodels"

PageItem {
    id: cameracaptionpage

    property var imagePath

    property bool locationSelected: false
    property var locationVar: ({})

    readonly property bool imageUploading: publishViewModel.isUploading

    PublishViewModel {
        id: publishViewModel
        onPublished: {
            pageLayout.removePages(homePage);
            pageLayout.primaryPage = homePage;

            Scripts.pushSingleImage(pageLayout.primaryPage, mediaId);
        }
    }

    LocationSearchViewModel {
        id: locationViewModel
    }

    header: PageHeaderItem {
        title: i18n.tr("Publish")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: IconsConstants.chevron_left
                onTriggered: {
                    pageLayout.removePages(cameracaptionpage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Share")
                iconName: IconsConstants.checkmark
                enabled: !imageUploading
                onTriggered: publishViewModel.publish(imagePath, caption.text, locationVar, disableCommentsSwitch.checked)
            }
        ]
    }

    Component.onCompleted: {
        locationViewModel.search();
    }

    Connections {
        target: mainView
        function onLocationSelected(location) {
            cameracaptionpage.locationSelected = true;
            cameracaptionpage.locationVar = location;
        }
    }

    Column {
        id: uploadProgressBarItem
        visible: imageUploading
        anchors.top: cameracaptionpage.header.bottom
        width: parent.width

        Rectangle {
            width: parent.width
            height: units.gu(5)
            color: Qt.lighter(LomiriColors.lightGrey, 1.2)

            Label {
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                text: uploadProgressBar.value == 100 ? i18n.tr("Saving") : i18n.tr("Posting")
            }
        }

        ProgressBar {
            id: uploadProgressBar
            width: parent.width
            maximumValue: 100
            minimumValue: 0
            value: publishViewModel.progress
        }
    }

    Column {
        width: parent.width
        anchors {
            left: parent.left
            right: parent.right
            top: !imageUploading ? cameracaptionpage.header.bottom : uploadProgressBarItem.bottom
            topMargin: units.gu(1)
        }

        Label {
            visible: text.length > 0
            width: parent.width - units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            color: LomiriColors.red
            text: publishViewModel.errorMessage
        }

        Row {
            width: parent.width
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
                topMargin: units.gu(1)
            }
            spacing: units.gu(1)

            Image {
                width: units.gu(8)
                height: width
                source: 'file://' + imagePath
                smooth: true
                cache: false
                clip: true
                fillMode: Image.PreserveAspectFit
            }

            TextArea {
                id: caption
                width: parent.width - units.gu(9)
                height: units.gu(8)
                placeholderText: i18n.tr("Write a caption...")
            }
        }

        Item {
            width: parent.width
            height: units.gu(1.5)
        }

        Rectangle {
            width: parent.width
            height: units.gu(0.17)
            color: Qt.lighter(LomiriColors.lightGrey, 1.1)
        }

        ListItem {
            height: addLocationLayout.height
            divider.visible: true
            onClicked: {
                pageLayout.pushToCurrent(cameracaptionpage, PagesConstants.search_location);
            }
            ListItemLayout {
                id: addLocationLayout
                padding.leading: 0
                padding.trailing: 0

                title.text: cameracaptionpage.locationSelected ? cameracaptionpage.locationVar.name : i18n.tr("Add Location")

                Item {
                    visible: cameracaptionpage.locationSelected
                    width: visible ? units.gu(2) : 0
                    height: width
                    SlotsLayout.position: SlotsLayout.Trailing

                    LineIcon {
                        anchors.centerIn: parent
                        name: "\uea63"
                        color: styleApp.common.iconActiveColor
                        iconSize: units.gu(2)
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            cameracaptionpage.locationSelected = false;
                            cameracaptionpage.locationVar = {};
                        }
                    }
                }
            }
        }

        ListItem {
            height: rankedLocationsLayout.height
            visible: locationViewModel.placesModel.count > 0
            divider.visible: true
            SlotsLayout {
                id: rankedLocationsLayout
                padding.leading: 0
                padding.trailing: 0

                mainSlot: ListView {
                    width: rankedLocationsLayout.width
                    height: units.gu(3)
                    orientation: Qt.Horizontal
                    clip: true
                    spacing: units.gu(0.5)
                    model: locationViewModel.placesModel

                    delegate: Item {
                        width: username_rect.width
                        height: username_rect.height
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: username_rect
                            height: username_label.height + units.gu(1.5)
                            width: username_label.width + units.gu(2.5)
                            color: LomiriColors.blue
                            radius: units.gu(0.3)
                            Label {
                                id: username_label
                                anchors.centerIn: parent
                                text: name
                                color: "#ffffff"
                                fontSize: "small"
                                font.weight: Font.DemiBold
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mainView.locationSelected({
                                        "name": name.replace("&", "%26"),
                                        "address": address.replace("&", "%26"),
                                        "lat": lat.toFixed(4),
                                        "lng": lng.toFixed(4),
                                        "external_id": external_id,
                                        "external_id_source": external_id_source
                                    });
                                }
                            }
                        }
                    }
                }
            }
        }

        ListItem {
            height: disableCommentsLayout.height
            divider.visible: true
            ListItemLayout {
                id: disableCommentsLayout
                padding.leading: 0
                padding.trailing: 0

                title.text: i18n.tr("Turn off commenting")

                Switch {
                    id: disableCommentsSwitch
                    SlotsLayout.position: SlotsLayout.Trailing
                    checked: false
                }
            }
        }
    }
}
