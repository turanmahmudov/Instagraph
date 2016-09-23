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
    id: userfollowerspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Followers")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    function userFollowersDataFinished(data) {
        userFollowersModel.clear()

        worker.sendMessage({'feed': 'UserFollowersPage', 'obj': data.users, 'model': userFollowersModel, 'clear_model': clear_models})

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
        getUserFollowers();
    }

    function getUserFollowers(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowersModel.clear()
            clear_models = true
        }
        instagram.getUserFollowers(userId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: userfollowerspage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: userFollowersModel
    }

    ListView {
        id: userFollowingsList
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: parent.bottom
            top: userfollowerspage.header.bottom
        }
        onMovementEnded: {
        }

        clip: true
        cacheBuffer: parent.height*2
        model: userFollowersModel
        delegate: ListItem {
            id: userFollowingsDelegate
            divider.visible: false
            height: entry_column.height + units.gu(2)

            Column {
                id: entry_column
                spacing: units.gu(1)
                width: parent.width
                y: units.gu(1)

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
                            text: Helper.formatUser(username)
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                            onLinkActivated: {
                                Scripts.linkClick(link)
                            }
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
            refreshing: list_loading && userFollowersModel.count == 0
            onRefresh: {
                list_loading = true
                getUserFollowers()
            }
        }
    }

    Connections{
        target: instagram
        onUserFollowersDataReady: {
            var data = JSON.parse(answer);
            userFollowersDataFinished(data);
        }
    }
}
