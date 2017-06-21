import QtQuick 2.4
import Ubuntu.Components 1.3

import "../js/Helper.js" as Helper

ListView {
    id: listView

    snapMode: ListView.SnapToItem
    orientation: Qt.Horizontal
    highlightMoveDuration: UbuntuAnimation.FastDuration
    highlightRangeMode: ListView.ApplyRange
    highlightFollowsCurrentItem: true

    delegate: ListItem {
        width: units.gu(20)
        height: suggestionsColumn.height
        divider.visible: false

        Column {
            id: suggestionsColumn
            width: parent.width
            spacing: units.gu(1)

            UbuntuShape {
                width: parent.width/2
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
                text: user.full_name ? user.full_name : user.username
                color: "#000000"
                fontSize: "small"
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                    }
                }
            }

            FollowComponent {
                width: units.gu(5)
                height: units.gu(3)
                friendship_var: {"following": false, "outgoing_request": false}
                userId: user.pk
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
