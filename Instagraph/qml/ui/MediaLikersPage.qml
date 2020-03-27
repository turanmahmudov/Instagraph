import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.1
import QtMultimedia 5.4

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: medialikerspage

    property var photoId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Likes")
    }

    function mediaLikersDataFinished(data) {
        mediaLikersModel.clear()

        worker.sendMessage({'feed': 'MediaLikersPage', 'obj': data.users, 'model': mediaLikersModel, 'clear_model': clear_models, 'color': theme.palette.normal.baseText})

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getMediaLikes();
    }

    function getMediaLikes(next_id)
    {
        clear_models = false
        if (!next_id) {
            mediaLikersModel.clear()
            clear_models = true
        }
        instagram.getMediaLikers(photoId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: medialikerspage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: mediaLikersModel
    }

    ListView {
        id: mediaLikersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: medialikerspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height*2
        model: mediaLikersModel
        delegate: ListItem {
            id: mediaLikersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
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

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: profile_pic_url
                    }

                    Column {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                        }

                        Text {
                            text: full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && mediaLikersModel.count == 0
            onRefresh: {
                list_loading = true
                getMediaLikes()
            }
        }
    }

    Connections{
        target: instagram
        onMediaLikersDataReady: {
            var data = JSON.parse(answer);
            mediaLikersDataFinished(data);
        }
    }
}
