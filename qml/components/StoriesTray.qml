import QtQuick 2.12
import Lomiri.Components 1.3
import QtGraphicalEffects 1.0

import "Constants"

Item {
    id: storiesTray

    width: parent.width
    height: parent.height

    property var currentDelegatePage: pageLayout.primaryPage
    property var allUsers: []
    property bool finishedLoading: false

    function checkVisible() {
        if (finishedLoading && storiesTrayModel.count == 0) {
            return false;
        }

        return true;
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/SimpleWorker.js"
        onMessage: {
        }
    }

    Component.onCompleted: {
        finishedLoading = false
        instagram.getReelsTrayFeed();
    }

    ListModel {
        id: storiesTrayModel
    }

    Item {
        width: activity.width
        height: width
        anchors.centerIn: parent
        opacity: !finishedLoading

        Behavior on opacity {
            LomiriNumberAnimation {
                duration: LomiriAnimation.SlowDuration
            }
        }

        ActivityIndicator {
            id: activity
            running: true
        }
    }

    ListView {
        id: storiesTrayList

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: units.gu(1)

        clip: true

        snapMode: ListView.SnapToItem
        orientation: Qt.Horizontal
        highlightMoveDuration: LomiriAnimation.FastDuration
        highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: true

        model: storiesTrayModel

        delegate: ListItem {
            width: storiesTray.width/5 + units.gu(1)
            height: storyColumn.height
            divider.visible: false

            Column {
                id: storyColumn
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(1)

                CircleImage {
                    width: parent.width
                    height: width
                    source: typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                    ringState: typeof seen != 'undefined' && seen !== 0 ? "seen" : "unseen"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.user_stories, {userId: user.pk, allUsers: allUsers});
                        }
                    }
                }

                Label {
                    text: user.username
                    color: styleApp.common.textColor
                    fontSize: "x-small"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min((parent.width+2), contentWidth)
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.user_stories, {userId: user.pk, allUsers: allUsers});
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: instagram
        onReelsTrayFeedDataReady:{
            var data = JSON.parse(answer);

            worker.sendMessage({'feed': 'StoriesTray', 'obj': data.tray, 'model': storiesTrayModel, 'clear_model': true})
            finishedLoading = true

            // Reset allUsers before rebuilding to prevent unbounded growth
            allUsers = []
            for (var i=0; i<data.tray.length; i++) {
                allUsers.push(data.tray[i].user.pk)
            }
        }
    }
}
