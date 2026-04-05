import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

// XMA (Cross-platform Media Attachment) - Rich media preview
Column {
    property bool isOutgoing: false
    property var itemMaxWidth

    spacing: units.gu(0.4)

    Rectangle {
        width: itemMaxWidth
        height: xmaColumn.height + units.gu(1)
        color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
        radius: units.gu(2)
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

        Column {
            id: xmaColumn
            width: parent.width
            spacing: units.gu(1)

            Item {
                width: parent.width
                height: units.gu(0.1)
            }

            // Header with profile pic and username
            Row {
                x: units.gu(1)
                width: parent.width - units.gu(2)
                height: units.gu(4)
                spacing: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter

                CircleImage {
                    anchors.verticalCenter: parent.verticalCenter
                    width: units.gu(3)
                    height: width
                    source: typeof xma_media_share.header_icon_url_info != 'undefined' ? xma_media_share.header_icon_url_info.url : ""
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: typeof xma_media_share.header_title_text != 'undefined' ? xma_media_share.header_title_text : ""
                    font.weight: Font.DemiBold
                    color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
                }
            }

            // Preview image
            Image {
                id: previewImage
                width: parent.width
                height: {
                    if (typeof xma_media_share.preview_url_info == 'undefined' || typeof xma_media_share.preview_url_info.width == 'undefined' || typeof xma_media_share.preview_url_info.height == 'undefined')
                        return 0;

                    var ratio = xma_media_share.preview_url_info.height / xma_media_share.preview_url_info.width;
                    var computed = width * ratio;
                    // Cap the height so tall images don't blow up the bubble
                    return Math.min(computed, width);
                }
                source: typeof xma_media_share.preview_url_info != 'undefined' && typeof xma_media_share.preview_url_info.url != 'undefined' ? xma_media_share.preview_url_info.url : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(width, height)
                smooth: true
                clip: true
                visible: source !== ""
            }

            // Caption text
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - units.gu(2)
                visible: typeof xma_media_share.title_text != 'undefined' && xma_media_share.title_text !== ""
                text: {
                    if (!visible)
                        return "";
                    var title = xma_media_share.title_text;
                    var lines = title.split('\n');
                    var firstLine = lines[0] || "";
                    return firstLine.length > 100 ? firstLine.substring(0, 97) + "..." : firstLine;
                }
                wrapMode: Text.WordWrap
                color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            }

            // Bottom spacer
            Item {
                width: parent.width
                height: units.gu(0.1)
            }
        }

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right;
            }
        }
    }
}
