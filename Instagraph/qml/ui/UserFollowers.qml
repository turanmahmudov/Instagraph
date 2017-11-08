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
            right: parent.right
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

                    CircleImage {
                        id: feed_user_profile_image
                        width: units.gu(5)
                        height: width
                        source: status == Image.Error ? "../images/not_found_user.jpg" : profile_pic_url
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
