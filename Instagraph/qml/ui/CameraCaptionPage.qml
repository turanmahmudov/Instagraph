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

    property var locationVar: {}

    property bool imageUploading: false

    header: PageHeader {
        title: i18n.tr("Publish")
        leadingActionBar.actions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: "back"
                onTriggered: {
                    pageLayout.pop();
                }
            }
        ]
        trailingActionBar.actions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Share")
                iconName: "tick"
                onTriggered: {
                    imageUploading = true
                    Scripts.publishImage(imagePath, caption.text, locationVar)
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
            width: parent.width
            showDivider: true
            onClicked: {
                var searchLocationPage = pageLayout.push(Qt.resolvedUrl("SearchLocation.qml"));

                searchLocationPage.locationSelected.connect(function(location) {
                    locationVar = location;

                    if (typeof location.address != 'undefined') {
                        addLocationButton.visible = false;
                        addLocationSpace.visible = true;
                        locationLabel.text = location.name;
                    }

                    //console.log(JSON.stringify(location));
                })
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                spacing: units.gu(1)

                Icon {
                    width: units.gu(2)
                    height: width
                    name: "location"
                }

                Item {
                    id: addLocationButton
                    width: parent.width - units.gu(3)
                    height: addLocationLabel.height

                    Label {
                        id: addLocationLabel
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: i18n.tr("Add Location")
                    }
                }

                Item {
                    id: addLocationSpace
                    visible: false
                    width: parent.width - units.gu(3)
                    height: addLocationLabel.height

                    Label {
                        id: locationLabel
                        width: parent.width - units.gu(3)
                        wrapMode: Text.WordWrap
                    }

                    Icon {
                        width: units.gu(2)
                        height: width
                        anchors.right: parent.right
                        name: "close"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                locationVar = {};
                                addLocationButton.visible = true;
                                addLocationSpace.visible = false;
                                locationLabel.text = "";
                            }
                        }
                    }
                }

            }
        }
    }

    Connections{
        target: instagram
        onImageConfigureDataReady: {
            //console.log(answer)
            pageStack.pop();
            pageStack.pop();
            pageStack.pop();
            pageLayout.push(tabs);

            var data = JSON.parse(answer);

            pageLayout.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: data.media.id});
        }
        onImageUploadProgressDataReady: {
            //console.log(answer);
            uploadProgressBar.value = answer
        }
    }
}
