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
    id: usersfollowingspage

    property var userId

    property bool list_loading: false
    property bool clear_models: true

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    header: PageHeaderItem {
        title: i18n.tr("Followings")
    }

    function userFollowingsDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = typeof data.next_max_id != 'undefined' ? data.next_max_id : ""
            more_available = typeof data.next_max_id != 'undefined'
            next_coming = true;

            worker.sendMessage({'feed': 'UserFollowingsPage', 'obj': data.users, 'model': userFollowingsModel, 'clear_model': clear_models})

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
        getUserFollowings();
    }

    function getUserFollowings(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowingsModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.getFollowing(userId, next_id);
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
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToCurrent(usersfollowingspage, Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: pk});
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
                    width: parent.width - followButton.width
                }

                FollowComponent {
                    id: followButton
                    height: units.gu(3.5)
                    friendship_var: {"following": true, "outgoing_request": false}
                    userId: pk
                    just_icon: false

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
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
        onFollowingDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
    }
}
