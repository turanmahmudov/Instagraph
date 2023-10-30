import QtQuick 2.12
import Lomiri.Components 1.3

import "../js/Helper.js" as Helper

ListView {
    id: listView

    snapMode: ListView.SnapToItem
    orientation: Qt.Horizontal
    highlightMoveDuration: LomiriAnimation.FastDuration
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

            CircleImage {
                width: parent.width/2
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                source: typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
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
                        pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                    }
                }
            }

            FollowComponent {
                height: units.gu(3.5)
                friendship_var: {"following": false, "outgoing_request": false}
                userId: user.pk
                just_icon: false
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
