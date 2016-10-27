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
    id: usersfollowingspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Followings")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    function userFollowingsDataFinished(data) {
        userFollowingsModel.clear()

        worker.sendMessage({'feed': 'UserFollowingsPage', 'obj': data.users, 'model': userFollowingsModel, 'clear_model': clear_models})

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
        getUserFollowings();
    }

    function getUserFollowings(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowingsModel.clear()
            clear_models = true
        }
        instagram.getUserFollowings(userId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: usersfollowingspage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: userFollowingsModel
    }

    ListView {
        id: userFollowingsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: usersfollowingspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height*2
        model: userFollowingsModel
        delegate: ListItem {
            id: userFollowingsDelegate
            divider.visible: false
            height: entry_column.height + units.gu(2)

            Column {
                id: entry_column
                spacing: units.gu(1)
                width: parent.width
                y: units.gu(1)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }

                Row {
                    spacing: units.gu(1)
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    Item {
                        width: units.gu(5)
                        height: width

                        UbuntuShape {
                            width: parent.width
                            height: width
                            radius: "large"

                            source: Image {
                                id: feed_user_profile_image
                                width: parent.width
                                height: width
                                source: status == Image.Error ? "../images/not_found_user.jpg" : profile_pic_url
                                fillMode: Image.PreserveAspectCrop
                                anchors.centerIn: parent
                                sourceSize: Qt.size(width,height)
                                smooth: true
                                clip: true
                            }
                        }

                        Item {
                            width: activity.width
                            height: width
                            anchors.centerIn: parent
                            opacity: feed_user_profile_image.status == Image.Loading

                            Behavior on opacity {
                                UbuntuNumberAnimation {
                                    duration: UbuntuAnimation.SlowDuration
                                }
                            }

                            ActivityIndicator {
                                id: activity
                                running: true
                            }
                        }
                    }

                    Column {
                        width: parent.width - units.gu(6)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: username
                            font.weight: Font.DemiBold
                            wrapMode: Text.WordWrap
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

            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameString: username});
            }
        }
        PullToRefresh {
            refreshing: list_loading && userFollowingsModel.count == 0
            onRefresh: {
                list_loading = true
                getUserFollowings()
            }
        }
    }

    Connections{
        target: instagram
        onUserFollowingsDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
    }
}
