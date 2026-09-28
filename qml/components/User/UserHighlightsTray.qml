import QtQuick 2.12
import ".."
import Lomiri.Components 1.3
import QtGraphicalEffects 1.0

import "../Constants"

ListView {
    id: userHighlightsTray
    clip: true

    property var allHighlights: []
    property var currentDelegatePage: pageLayout.primaryPage

    snapMode: ListView.SnapToItem
    orientation: Qt.Horizontal
    highlightMoveDuration: LomiriAnimation.FastDuration
    highlightRangeMode: ListView.ApplyRange
    highlightFollowsCurrentItem: true

    delegate: ListItem {
        width: units.gu(10)
        height: storyColumn.height
        divider.visible: false

        Column {
            id: storyColumn
            width: parent.width - units.gu(2)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(0.5)

            CircleImage {
                width: parent.width
                height: width
                source: typeof cover_media.cropped_image_version != 'undefined' ? cover_media.cropped_image_version.url : "../../images/not_found_user.jpg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.highlight_stories, {
                            highlightId: id,
                            allHighlights: allHighlights
                        });
                    }
                }
            }

            Label {
                text: title
                color: styleApp.common.textColor
                fontSize: "x-small"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.highlight_stories, {
                            highlightId: id,
                            allHighlights: allHighlights
                        });
                    }
                }
            }
        }
    }
}
