import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: likedmediapage

    header: PageHeader {
        title: i18n.tr("Likes")
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool list_loading: false

    property bool isEmpty: false

    function likedMediaDataFinished(data) {
        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'searchPage', 'obj': data.items, 'model': likedMediaModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getLikedMedia();
    }

    function getLikedMedia(next_id)
    {
        clear_models = false
        if (!next_id) {
            likedMediaModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getLikedMedia(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: likedmediapage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: likedMediaModel
    }

    GridView {
        id: gridView
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: likedmediapage.header.bottom
        }
        width: parent.width
        height: parent.height
        cellWidth: gridView.width/3
        cellHeight: cellWidth
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getLikedMedia(next_max_id);
            }
        }
        model: likedMediaModel
        delegate: ListItem {
            width: parent.width
            height: gridView.cellHeight

            Item {
                width: gridView.cellWidth
                height: gridView.cellHeight

                Image {
                    property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

                    id: feed_image
                    width: parent.width
                    height: width
                    source: bestImage.url
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width,height)
                    asynchronous: true
                    cache: true
                    smooth: true
                }
                Icon {
                    visible: media_type == 2
                    width: units.gu(3)
                    height: width
                    name: "camcorder"
                    color: "#ffffff"
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(2)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(2)
                }

                Item {
                    width: activity2.width
                    height: width
                    anchors.centerIn: parent
                    opacity: feed_image.status == Image.Loading

                    Behavior on opacity {
                        UbuntuNumberAnimation {
                            duration: UbuntuAnimation.SlowDuration
                        }
                    }

                    ActivityIndicator {
                        id: activity2
                        running: true
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: id});
                    }
                }
            }
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && likedMediaModel.count == 0
            onRefresh: {
                list_loading = true
                getLikedMedia()
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: likedmediapage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        icon: true
        iconName: "stock_image"

        description: i18n.tr("No photos or videos yet!")
    }

    Connections{
        target: instagram
        onLikedMediaDataReady: {
            var new_answer = answer.replace(/([\[:])?(\d{18,})([,\}\]])/g, "$1\"$2\"$3");
            var data = JSON.parse(new_answer);
            likedMediaDataFinished(data);
        }
    }
}
