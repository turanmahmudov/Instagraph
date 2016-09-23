import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtPositioning 5.2

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
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

    header: PageHeader {
        title: i18n.tr("Search")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        /*trailingActionBar {
            numberOfSlots: 1
            actions: [addPeopleAction]
        }*/
        contents: TextField {
            id: searchInput
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            StyleHints {
                backgroundColor: "#0D4168"
                foregroundColor: "#ffffff"
                borderColor: "#0D4168"
                textColor: "#ffffff"
                placeholderTextColor: "#ffffff"
                selectedTextColor: "#ffffff"
            }
            primaryItem: Icon {
                anchors.leftMargin: units.gu(0.2)
                height: parent.height*0.5
                width: height
                name: "find"
            }
            color: "#ffffff"
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onAccepted: {
                instagram.searchLocation(coord.latitude, coord.longitude, text);
            }
        }
    }

    signal cancel()
    signal locationSelected(var location)

    function searchLocationDataFinished(data) {
        searchPlacesModel.clear();

        worker.sendMessage({'feed': 'searchPage', 'obj': data.venues, 'model': searchPlacesModel, 'clear_model': true})
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: searchlocationpage.header.bottom
        visible: instagram.busy
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
            cacheBuffer: searchlocationpage.height*2
            model: searchPlacesModel
            delegate: ListItem {
                id: searchPlacesDelegate
                divider.visible: false
                height: entry_column.height + units.gu(1)

                Column {
                    id: entry_column
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    Item {
                        width: parent.width
                        height: units.gu(0.1)
                    }

                    Row {
                        spacing: units.gu(1)
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        Item {
                            width: units.gu(5)
                            height: width

                            Icon {
                                anchors.centerIn: parent
                                width: units.gu(3)
                                height: width
                                name: "location"
                            }
                        }

                        Column {
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: name
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: address
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                width: parent.width
                            }
                        }
                    }
                }

                onClicked: {
                    locationSelected({"name":name.replace("&", "%26"), "address":address.replace("&", "%26"), "lat":lat.toFixed(4), "lng":lng.toFixed(4), "external_id":external_id, "external_id_source":external_id_source})

                    pageStack.pop()
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
