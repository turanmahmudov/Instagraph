import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12
import Ubuntu.Components.ListItems 1.3 as ListItem

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: cameracaptionpage

    property var imagePath

    property bool locationSelected: false
    property var locationVar: ({})

    property bool imageUploading: false

    header: PageHeaderItem {
        title: i18n.tr("Publish")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: "\uea5a"
                onTriggered: {
                    pageLayout.removePages(cameracaptionpage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Share")
                iconName: "\uea55"
                onTriggered: {
                    imageUploading = true
                    Scripts.publishImage(imagePath, caption.text, locationVar, disableCommentsSwitch.checked)
                }
            }

        ]
    }

    Column {
        id: uploadProgressBarItem
        visible: imageUploading
        anchors.top: cameracaptionpage.header.bottom
        width: parent.width

        Rectangle {
            width: parent.width
            height: units.gu(5)
            color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

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
            value: 0
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
            color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
        }

        ListItem.Base {
            height: addLocationLayout.height
            divider.visible: true
            onClicked: {
                pageLayout.pushToCurrent(cameracaptionpage, Qt.resolvedUrl("SearchLocation.qml"));

                mainView.locationSelected.connect(function(location) {
                    locationSelected = true
                    locationVar = location;
                })
            }
            ListItemLayout {
                id: addLocationLayout
                padding.leading: 0
                padding.trailing: 0

                title.text: locationSelected ? locationVar.name : i18n.tr("Add Location")

                Item {
                    visible: locationSelected
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
                            locationSelected = false
                            locationVar = {}
                        }
                    }
                }
            }
        }

        ListItem.Base {
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

    Connections{
        target: instagram
        onImageConfigureDataReady: {
            pageLayout.removePages(homePage)
            pageLayout.primaryPage = homePage

            var data = JSON.parse(answer);

            Scripts.pushSingleImage(pageLayout.primaryPage, data.media.id)
        }
        onImageUploadProgressDataReady: {
            uploadProgressBar.value = answer
        }
    }
}
