import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12
import QtPositioning 5.2

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

    property var coord: {'latitude':positionSource.position.coordinate.latitude, 'longitude':positionSource.position.coordinate.longitude}

    PositionSource {
        id: positionSource
        updateInterval: 1000 //1 seconds (?)
        active: true
        onPositionChanged: {
            coord.latitude = positionSource.position.coordinate.latitude;
            coord.longitude = positionSource.position.coordinate.longitude;

            instagram.searchLocation(coord.latitude, coord.longitude, "");
        }
    }

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

    function searchLocationDataFinished(data) {
        searchPlacesModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.venues, 'model': searchPlacesModel, 'clear_model': true})
    }

    WorkerScript {
        id: worker
        source: "../js/TimelineWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    ListModel {
        id: searchPlacesModel
    }

    Component.onCompleted: {
        instagram.searchLocation(coord.latitude, coord.longitude, "");

        mainView.locationSelected.connect(function(location) {
            cameracaptionpage.locationSelected = true
            cameracaptionpage.locationVar = location;
        })
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

        ListItem {
            height: addLocationLayout.height
            divider.visible: true
            onClicked: {
                pageLayout.pushToCurrent(cameracaptionpage, Qt.resolvedUrl("SearchLocation.qml"));
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
                            cameracaptionpage.locationSelected = false
                            cameracaptionpage.locationVar = {}
                        }
                    }
                }
            }
        }

        ListItem {
            height: rankedLocationsLayout.height
            visible: searchPlacesModel.count > 0
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
                    model: searchPlacesModel

                    delegate: Item {
                        width: username_rect.width
                        height: username_rect.height
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: username_rect
                            height: username_label.height + units.gu(1.5)
                            width: username_label.width + units.gu(2.5)
                            color: UbuntuColors.blue
                            radius: units.gu(0.3)
                            Label {
                                anchors.centerIn: parent
                                id: username_label
                                text: name
                                color: "#ffffff"
                                fontSize: "small"
                                font.weight: Font.DemiBold
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    mainView.locationSelected({"name":name.replace("&", "%26"), "address":address.replace("&", "%26"), "lat":lat.toFixed(4), "lng":lng.toFixed(4), "external_id":external_id, "external_id_source":external_id_source})
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
        onSearchLocationDataReady: {
            var data = JSON.parse(answer);
            searchLocationDataFinished(data);
        }
    }
}
