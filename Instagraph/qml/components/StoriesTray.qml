import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: storiesTray

    width: parent.width
    height: parent.height

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        instagram.getReelsTrayFeed();
    }

    ListModel {
        id: storiesTrayModel
    }

    Rectangle {
        anchors.fill: parent
        color: "#fbfbfb"
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
        highlightMoveDuration: UbuntuAnimation.FastDuration
        highlightRangeMode: ListView.ApplyRange
        highlightFollowsCurrentItem: true

        model: storiesTrayModel

        delegate: ListItem {
            width: units.gu(10)
            height: storyColumn.height
            divider.visible: false

            Column {
                id: storyColumn
                width: parent.width
                spacing: units.gu(1)

                UbuntuShape {
                    width: parent.width*0.8
                    height: width
                    radius: "large"
                    anchors.horizontalCenter: parent.horizontalCenter

                    source: Image {
                        anchors {
                            centerIn: parent
                        }
                        width: parent.width
                        height: width
                        source: typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        asynchronous: true
                        cache: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                        }
                    }
                }

                Label {
                    text: user.username
                    color: "#000000"
                    fontSize: "small"
                    anchors.horizontalCenter: parent.horizontalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
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
            //console.log(answer)

            worker.sendMessage({'feed': 'StoriesTray', 'obj': data.tray, 'model': storiesTrayModel, 'clear_model': true})
        }

        onUserReelsMediaFeedDataReady: {
            /*
            while(!dataLoaded){}
            var data = JSON.parse(answer);
            for(var j=0;j<data.items.length;j++){
                recentMediaModel.append(data.items[j]);
            }
            */
        }
    }
}
