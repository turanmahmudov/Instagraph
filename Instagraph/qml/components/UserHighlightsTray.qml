import QtQuick 2.12
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

ListView {
    id: userHighlightsTray
    clip: true

    property var allHighlights: []
    property var currentDelegatePage: pageLayout.primaryPage

    snapMode: ListView.SnapToItem
    orientation: Qt.Horizontal
    highlightMoveDuration: UbuntuAnimation.FastDuration
    highlightRangeMode: ListView.ApplyRange
    highlightFollowsCurrentItem: true

    delegate: ListItem {
        width: userHighlightsTray.width/5 + units.gu(1)
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
                source: typeof cover_media.cropped_image_version != 'undefined' ? cover_media.cropped_image_version.url : "../images/not_found_user.jpg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/HighlightStoriesPage.qml"), {highlightId: id, allHighlights: allHighlights});
                    }
                }
            }

            Label {
                text: title
                color: styleApp.common.textColor
                fontSize: "x-small"
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min((parent.width+2), contentWidth)
                clip: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/HighlightStoriesPage.qml"), {highlightId: id, allHighlights: allHighlights});
                    }
                }
            }
        }
    }
}
