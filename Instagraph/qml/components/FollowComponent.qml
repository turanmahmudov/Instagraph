import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Item {

    width: followRectangle.width

    // Theme
    property string followColor: "#ffffff"
    property string followBgColor: UbuntuColors.green
    property string followBorderColor: UbuntuColors.green
    property string followIcon: "add"

    property string followingColor: "#000000"
    property string followingBgColor: "transparent"
    property string followingBorderColor: "#000000"
    property string followingIcon: "tick"

    property string requestedColor: "#ffffff"
    property string requestedBgColor: "#666666"
    property string requestedBorderColor: "#666666"
    property string requestedIcon: "clock"

    property bool just_icon: true

    property var friendship_var
    property var userId
    property var latest_follow_request

    // Default
    property string firstIconName: ""
    property string firstIconColor: ""
    property string secondIconColor: ""
    property string labelText: ""
    property string labelColor: ""
    property string rectangleColor: ""
    property string rectangleBorderColor: ""

    Component.onCompleted: {
        if (friendship_var) {
            if (friendship_var.following) {
                firstIconName = followingIcon
                firstIconColor = followingColor
                secondIconColor = followingColor
                labelText = i18n.tr("Following")
                labelColor = followingColor
                rectangleColor = followingBgColor
                rectangleBorderColor = followingBorderColor
            } else if (friendship_var.outgoing_request) {
                firstIconName = requestedIcon
                firstIconColor = requestedColor
                secondIconColor = requestedColor
                labelText = i18n.tr("Requested")
                labelColor = requestedColor
                rectangleColor = requestedBgColor
                rectangleBorderColor = requestedBorderColor
            } else {
                firstIconName = followIcon
                firstIconColor = followColor
                secondIconColor = followColor
                labelText = i18n.tr("Follow")
                labelColor = followColor
                rectangleColor = followBgColor
                rectangleBorderColor = followBorderColor
            }
        } else {
            firstIconName = followIcon
            firstIconColor = followColor
            secondIconColor = followColor
            labelText = i18n.tr("Follow")
            labelColor = followColor
            rectangleColor = followBgColor
            rectangleBorderColor = followBorderColor
        }
    }

    function followDataFinished(data) {
        if (userId == latest_follow_request) {
            if (data.friendship_status) {
                if (data.friendship_status.outgoing_request && !data.friendship_status.following) {
                    // requested
                    friendship_var.outgoing_request = true
                    friendship_var.following = false

                    firstIconName = requestedIcon
                    firstIconColor = requestedColor
                    secondIconColor = requestedColor
                    labelText = i18n.tr("Requested")
                    labelColor = requestedColor
                    rectangleColor = requestedBgColor
                    rectangleBorderColor = requestedBorderColor
                } else if (!data.friendship_status.outgoing_request && !data.friendship_status.following) {
                    // unfollow
                    friendship_var.outgoing_request = false
                    friendship_var.following = false

                    firstIconName = followIcon
                    firstIconColor = followColor
                    secondIconColor = followColor
                    labelText = i18n.tr("Follow")
                    labelColor = followColor
                    rectangleColor = followBgColor
                    rectangleBorderColor = followBorderColor
                } else if (!data.friendship_status.outgoing_request && data.friendship_status.following) {
                    // follow
                    friendship_var.outgoing_request = false
                    friendship_var.following = true

                    firstIconName = followingIcon
                    firstIconColor = followingColor
                    secondIconColor = followingColor
                    labelText = i18n.tr("Following")
                    labelColor = followingColor
                    rectangleColor = followingBgColor
                    rectangleBorderColor = followingBorderColor
                }

                latest_follow_request = 0
            }
        }
    }

    Rectangle {
        id: followRectangle
        width: just_icon ? units.gu(5) : units.gu(12)
        height: units.gu(3.5)
        radius: units.gu(0.3)
        border.color: rectangleBorderColor
        color: rectangleColor

        Row {
            id: followRow
            anchors.centerIn: parent

            Loader {
                sourceComponent: just_icon ? iconFollowComponent : labelFollowComponent
            }
        }

        Component {
            id: iconFollowComponent

            Row {
                anchors.centerIn: parent

                Icon {
                    id: followRectangleFirstIcon
                    anchors.verticalCenter: parent.verticalCenter
                    name: firstIconName
                    color: firstIconColor
                    width: units.gu(1.5)
                    height: width
                }

                Icon {
                    id: followRectangleSecondIcon
                    anchors.verticalCenter: parent.verticalCenter
                    name: "contact"
                    color: secondIconColor
                    width: units.gu(2)
                    height: width
                }
            }
        }

        Component {
            id: labelFollowComponent

            Row {
                anchors.centerIn: parent

                Label {
                    id: followRectangleLabel
                    anchors.verticalCenter: parent.verticalCenter
                    text: labelText
                    color: labelColor
                }
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

/*
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
*/
