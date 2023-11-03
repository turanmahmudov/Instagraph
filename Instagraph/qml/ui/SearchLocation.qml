import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtPositioning 5.2

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: searchlocationpage

    property var coord: {'latitude':positionSource.position.coordinate.latitude, 'longitude':positionSource.position.coordinate.longitude}

    PositionSource {
        id: positionSource
        updateInterval: 1000 //1 seconds (?)
        active: true
        onPositionChanged: {
            coord.latitude = positionSource.position.coordinate.latitude;
            coord.longitude = positionSource.position.coordinate.longitude;

            instagram.searchLocation(coord.latitude, coord.longitude, searchInput.text);
        }
    }

    header: PageHeaderItem {
        title: i18n.tr("Search")
        contents: TextField {
            id: searchInput
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            primaryItem: LineIcon {
                anchors.leftMargin: units.gu(0.2)
                iconSize: parent.height*0.4
                active: false
                name: "\ueb7b"
            }
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onAccepted: {
                instagram.searchLocation(coord.latitude, coord.longitude, text);
            }
        }
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

    Loader {
        id: viewLoader_search
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: searchlocationpage.header.bottom
        }
        active: searchPlacesList
        sourceComponent: searchPlacesList
    }

    Component {
        id: searchPlacesList

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: searchlocationpage.height
            model: searchPlacesModel
            delegate: ListItem {
                id: searchPlacesDelegate
                height: layout.height
                divider.visible: false
                onClicked: {
                    mainView.locationSelected({"name":name.replace("&", "%26"), "address":address.replace("&", "%26"), "lat":lat.toFixed(4), "lng":lng.toFixed(4), "external_id":external_id, "external_id_source":external_id_source})

                    pageLayout.removePages(searchlocationpage)
                }

                SlotsLayout {
                    id: layout
                    anchors.centerIn: parent

                    padding.leading: 0
                    padding.trailing: 0
                    padding.top: units.gu(1)
                    padding.bottom: units.gu(1)

                    mainSlot: Row {
                        id: label
                        spacing: units.gu(1)
                        width: parent.width - units.gu(5)

                        Item {
                            width: units.gu(5)
                            height: width

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(LomiriColors.lightGrey, 1.1)
                                radius: width/2

                                LineIcon {
                                    anchors.centerIn: parent
                                    width: units.gu(3)
                                    height: width
                                    name: "\ueb1c"
                                }
                            }
                        }

                        Column {
                            width: parent.width
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: name
                                wrapMode: Text.WordWrap
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: address
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                            }
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onSearchLocationDataReady: {
            var data = JSON.parse(answer);
            searchLocationDataFinished(data);
        }
    }
}
