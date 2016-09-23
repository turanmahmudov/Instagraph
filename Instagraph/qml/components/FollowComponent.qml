import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Item {

    property var friendship_var
    property var userId
    property var latest_follow_request

    function followDataFinished(data) {
        if (userId == latest_follow_request) {
            if (data.friendship_status) {
                if (data.friendship_status.outgoing_request && !data.friendship_status.following) {
                    // requested
                    friendship_var.outgoing_request = true
                    friendship_var.following = false

                    followRectangle.border.color = "#666666"
                    followRectangle.color = "#666666"
                    followRectangleFirstIcon.name = "clock"
                    followRectangleFirstIcon.color = "white"
                    followRectangleSecondIcon.color = "white"
                } else if (!data.friendship_status.outgoing_request && !data.friendship_status.following) {
                    // unfollow
                    friendship_var.outgoing_request = false
                    friendship_var.following = false

                    followRectangle.border.color = "#003569"
                    followRectangle.color = "transparent"
                    followRectangleFirstIcon.name = "add"
                    followRectangleFirstIcon.color = "#003569"
                    followRectangleSecondIcon.color = "#003569"
                } else if (!data.friendship_status.outgoing_request && data.friendship_status.following) {
                    // follow
                    friendship_var.outgoing_request = false
                    friendship_var.following = true

                    followRectangle.border.color = UbuntuColors.green
                    followRectangle.color = UbuntuColors.green
                    followRectangleFirstIcon.name = "tick"
                    followRectangleFirstIcon.color = "white"
                    followRectangleSecondIcon.color = "white"
                }

                latest_follow_request = 0
            }
        }
    }

    Rectangle {
        id: followRectangle
        width: units.gu(5)
        height: units.gu(3)
        radius: units.gu(0.2)
        border.color: friendship_var && friendship_var.following ? UbuntuColors.green : (friendship_var && friendship_var.outgoing_request ? "#666666" : "#003569")
        color: friendship_var && friendship_var.following ? UbuntuColors.green : (friendship_var && friendship_var.outgoing_request ? "#666666" : "transparent")

        Row {
            anchors.centerIn: parent

            Icon {
                id: followRectangleFirstIcon
                anchors.verticalCenter: parent.verticalCenter
                name: friendship_var && friendship_var.following ? "tick" : (friendship_var && friendship_var.outgoing_request ? "clock" : "add")
                color: friendship_var && friendship_var.following ? "white" : (friendship_var && friendship_var.outgoing_request ? "white" : "#003569")
                width: units.gu(1.5)
                height: width
            }

            Icon {
                id: followRectangleSecondIcon
                anchors.verticalCenter: parent.verticalCenter
                name: "contact"
                color: friendship_var && friendship_var.following ? "white" : (friendship_var && friendship_var.outgoing_request ? "white" : "#003569")
                width: units.gu(2)
                height: width
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (friendship_var && (friendship_var.following || friendship_var.outgoing_request)) {
                    // unfollow
                    latest_follow_request = userId
                    instagram.unFollow(userId)
                } else {
                    // follow
                    latest_follow_request = userId
                    instagram.follow(userId)
                }
            }
        }
    }

    Connections{
        target: instagram
        onFollowDataReady: {
            if (userId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
        onUnFollowDataReady: {
            if (userId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
    }
}
