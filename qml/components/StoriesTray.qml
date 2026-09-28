import QtQuick 2.12
import Lomiri.Components 1.3

import "Constants"

Item {
    id: storiesTray

    width: parent.width
    height: parent.height

    property var currentDelegatePage: pageLayout.primaryPage
    property var allUsers: []
    property bool finishedLoading: false
    property ListModel model: ListModel {}

    function checkVisible() {
        if (finishedLoading && model.count == 0) {
            return false;
        }

        return true;
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

        model: storiesTray.model

        delegate: ListItem {
            width: storiesTray.width / 5 + units.gu(1)
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
                            pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.user_stories, {
                                userId: user.pk,
                                allUsers: allUsers
                            });
                        }
                    }
                }

                Label {
                    text: user.username
                    color: styleApp.common.textColor
                    fontSize: "x-small"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.min((parent.width + 2), contentWidth)
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.user_stories, {
                                userId: user.pk,
                                allUsers: allUsers
                            });
                        }
                    }
                }
            }
        }
    }
}
