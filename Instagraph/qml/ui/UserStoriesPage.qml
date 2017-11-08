import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: userstoriespage

    header: PageHeader {
        StyleHints {
            backgroundColor: "transparent"
            foregroundColor: "#ffffff"
            dividerColor: "transparent"
        }
        contents: Rectangle {
            anchors.fill: parent
            color: "transparent"

            Row {
                spacing: units.gu(1)
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Item {
                    width: units.gu(4)
                    height: width

                    CircleImage {
                        id: feed_user_profile_image
                        width: parent.width
                        height: width
                        source: user.profile_pic_url
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                        }
                    }
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: user.username
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: "#ffffff"
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                        }
                    }
                }

                Label {
                    id: timeAgo
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }
                }
            }
        }
    }

    property var userId
    property var user
    property int progressTime: 0

    property var allUsers: []

    function userReelsMediaFeedDataFinished(data) {
        worker.sendMessage({'feed': 'userStoriesPage', 'obj': data.items, 'model': userStoriesModel, 'clear_model': true})

        user = data.user

        timeAgo.text = Helper.milisecondsToString(data.items[0].taken_at, true)

        progressTimer.stop()
        progressTime = 0
        timer.stop()
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getUserReelsMediaFeed() {
        instagram.getUserReelsMediaFeed(userId);
    }

    Component.onCompleted: {
        getUserReelsMediaFeed()
    }

    Timer {
        id: timer
        interval: 4000
        running: false
        repeat: false
        onTriggered: {
            userStoriesList.nextSlide()
        }
    }

    Timer {
        id: progressTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            progressTime += 100
        }
    }

    Row {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            topMargin: units.gu(0.5)
        }
        z: 100
        spacing: units.gu(0.5)

        Repeater {
            id: progressRepeater
            model: userStoriesModel.count

            ProgressBar {
                width: (parent.width - (userStoriesModel.count-1)*units.gu(0.5))/userStoriesModel.count
                value: index == userStoriesList.currentIndex ? progressTime : (index < userStoriesList.currentIndex ? 4000 : 0)
                minimumValue: 0
                maximumValue: 4000
            }
        }
    }

    ListModel {
        id: userStoriesModel
    }

    ListView {
        id: userStoriesList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        snapMode: ListView.SnapOneItem
        orientation: Qt.Horizontal
        highlightMoveDuration: UbuntuAnimation.FastDuration
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        clip: true
        interactive: false

        model: userStoriesModel
        delegate: Item {
            width: userstoriespage.width
            height: width/image_versions2.candidates[0].width*image_versions2.candidates[0].height

            Image {
                id: feed_image
                width: parent.width
                height:parent.height
                fillMode: Image.PreserveAspectCrop
                source: image_versions2.candidates[0].url
                sourceSize: Qt.size(width,height)
                asynchronous: true
                cache: true // maybe false
                smooth: false

                onStatusChanged: {
                    if (status == Image.Ready) {
                        if (userStoriesList.currentIndex == 0) {
                            progressTime = 0
                            progressTimer.start()
                            timer.start()
                        }
                    }
                }

                Connections {
                    target: userStoriesList
                    onCurrentIndexChanged: {
                        if (feed_image.status == Image.Ready) {
                            progressTime = 0
                            progressTimer.start()
                            timer.start()
                        }
                    }
                }
            }

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    userStoriesList.nextSlide()
                }
                onPressAndHold: {
                    timer.stop()
                    progressTimer.stop()
                }
                onReleased: {
                    timer.interval = 4000-progressTime
                    timer.start()
                    progressTimer.start()
                }
            }
        }

        // Go to next slide, if possible
        function nextSlide() {
            if (userStoriesList.currentIndex < userStoriesList.model.count-1) {
                userStoriesList.currentIndex++
                timeAgo.text = Helper.milisecondsToString(userStoriesModel.get(userStoriesList.currentIndex).taken_at, true)
            } else {
                if (allUsers.indexOf(userId) != allUsers.length-1) {
                    progressTimer.stop()
                    progressTime = 0
                    timer.stop()

                    // next user
                    userId = allUsers[allUsers.indexOf(userId)+1]
                    getUserReelsMediaFeed()
                }
            }
        }

        // Go to previous slide, if possible
        function previousSlide() {
            if (userStoriesList.currentIndex > 0) {
                userStoriesList.currentIndex--
                timeAgo.text = Helper.milisecondsToString(userStoriesModel.get(userStoriesList.currentIndex).taken_at, true)
            } else {
                if (allUsers.indexOf(userId) != 0) {
                    progressTimer.stop()
                    progressTime = 0
                    timer.stop()

                    // prev user
                    userId = allUsers[allUsers.indexOf(userId)-1]
                    getUserReelsMediaFeed()
                }
            }
        }
    }

    Connections{
        target: instagram
        onUserReelsMediaFeedDataReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            userReelsMediaFeedDataFinished(data)
        }
    }
}
