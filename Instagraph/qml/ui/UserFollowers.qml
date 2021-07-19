import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: userfollowerspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    header: PageHeaderItem {
        title: i18n.tr("Followers")
    }

    function userFollowersDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = typeof data.next_max_id != 'undefined' ? data.next_max_id : ""
            more_available = typeof data.next_max_id != 'undefined'
            next_coming = true;

            worker.sendMessage({'feed': 'UserFollowersPage', 'obj': data.users, 'model': userFollowersModel, 'clear_model': clear_models})

            next_coming = false;
        }

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
            next_max_id = ""
            clear_models = true
        }
        instagram.getFollowers(userId, next_id);
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
            if (atYEnd && more_available && !next_coming) {
                getUserFollowers(next_max_id)
            }
        }

        clip: true
        cacheBuffer: parent.height*2
        model: userFollowersModel
        delegate: ListItem {
            id: userFollowersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToCurrent(userfollowerspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: UserRowSlot {
                    id: label
                    width: parent.width
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
        onFollowersDataReady: {
            var data = JSON.parse(answer);
            userFollowersDataFinished(data);
        }
    }
}
