import QtQuick 2.12
import Lomiri.Components 1.3

Item {
    id: root

    width: followButton.width
    height: followButton.height

    property var userId
    property var friendship: null
    property bool showLabel: false

    readonly property bool isFollowing: friendship ? (friendship.following || false) : false
    readonly property bool isRequested: friendship ? (friendship.outgoing_request || false) : false
    readonly property bool isUnfollowed: !isFollowing && !isRequested

    property int pendingRequestUserId: 0

    QtObject {
        id: styles

        readonly property var follow: ({
            icon: "add",
            label: i18n.tr("Follow"),
            textColor: "#ffffff",
            backgroundColor: LomiriColors.green,
            borderColor: LomiriColors.green
        })

        readonly property var following: ({
            icon: "tick",
            label: i18n.tr("Following"),
            textColor: styleApp.common.outlineButtonTextColor,
            backgroundColor: "transparent",
            borderColor: styleApp.common.outlineButtonBorderColor
        })

        readonly property var requested: ({
            icon: "clock",
            label: i18n.tr("Requested"),
            textColor: "#ffffff",
            backgroundColor: "#666666",
            borderColor: "#666666"
        })

        property var current: follow
    }

    function updateStyles() {
        if (isFollowing) {
            styles.current = styles.following
        } else if (isRequested) {
            styles.current = styles.requested
        } else {
            styles.current = styles.follow
        }
    }

    function handleFollowResponse(data) {
        if (!data || !data.friendship_status || userId !== pendingRequestUserId) {
            return
        }

        if (friendship) {
            friendship.following = data.friendship_status.following
            friendship.outgoing_request = data.friendship_status.outgoing_request
        }

        updateStyles()
        pendingRequestUserId = 0
    }

    function toggleFollow() {
        if (!userId) return

        pendingRequestUserId = userId

        if (isFollowing || isRequested) {
            instagram.unFollow(userId)
        } else {
            instagram.follow(userId)
        }
    }

    Component.onCompleted: updateStyles()
    onIsFollowingChanged: updateStyles()
    onIsRequestedChanged: updateStyles()

    Rectangle {
        id: followButton
        width: showLabel ? units.gu(12) : units.gu(5)
        height: units.gu(3.5)
        radius: units.gu(0.3)
        color: styles.current.backgroundColor
        border.color: styles.current.borderColor

        Row {
            anchors.centerIn: parent
            spacing: units.gu(0.5)

            Icon {
                visible: !showLabel
                anchors.verticalCenter: parent.verticalCenter
                name: styles.current.icon
                color: styles.current.textColor
                width: units.gu(1.5)
                height: width
            }

            Icon {
                visible: !showLabel
                anchors.verticalCenter: parent.verticalCenter
                name: "contact"
                color: styles.current.textColor
                width: units.gu(2)
                height: width
            }

            Label {
                visible: showLabel
                anchors.verticalCenter: parent.verticalCenter
                text: styles.current.label
                color: styles.current.textColor
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: toggleFollow()
        }
    }

    Connections {
        target: instagram
        
        onFollowDataReady: {
            var data = JSON.parse(answer)
            handleFollowResponse(data)
        }
        
        onUnfollowDataReady: {
            var data = JSON.parse(answer)
            handleFollowResponse(data)
        }
    }
}
