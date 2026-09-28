import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Constants"

import "../../js/Helper.js" as Helper
import "../../js/Scripts.js" as Scripts

Column {
    property bool isOutgoing: false
    property var itemMaxWidth
    property var itemSmallWidth

    spacing: units.gu(0.4)

    Loader {
        sourceComponent: story_share.is_linked === false ? noStoryShareComponent : storyShareComponent

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right;
            }
        }
    }

    Component {
        id: storyShareComponent

        Item {
            width: storyShareRow.width
            height: storyShareRow.height

            Row {
                id: storyShareRow

                Rectangle {
                    visible: isOutgoing == false
                    width: visible ? units.gu(0.1) : 0
                    height: Math.max(parent.height, units.gu(5))
                    color: LomiriColors.lightGrey
                }
                Item {
                    visible: isOutgoing == false
                    width: visible ? units.gu(0.5) : 0
                    height: visible ? units.gu(1) : 0
                }

                Column {
                    spacing: units.gu(0.1)
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        text: isOutgoing ? i18n.tr("You sent %1's story.").arg(story_share.media.user.username) : i18n.tr("Sent %1's story.").arg(story_share.media.user.username)
                        fontSize: "small"
                        color: LomiriColors.darkGrey
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        width: contentWidth

                        horizontalAlignment: Text.AlignRight
                    }

                    Image {
                        width: itemSmallWidth
                        height: width / story_share.media.image_versions2.candidates[0].width * story_share.media.image_versions2.candidates[0].height
                        source: story_share.media.image_versions2.candidates[0].url
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width, height)
                        smooth: true
                        clip: true

                        Component.onCompleted: {
                            if (isOutgoing) {
                                anchors.right = parent.right;
                            }
                        }
                    }
                }

                Item {
                    visible: isOutgoing
                    width: visible ? units.gu(0.5) : 0
                    height: visible ? units.gu(1) : 0
                }
                Rectangle {
                    visible: isOutgoing
                    width: visible ? units.gu(0.1) : 0
                    height: Math.max(parent.height, units.gu(5))
                    color: LomiriColors.lightGrey
                }

                Component.onCompleted: {
                    if (isOutgoing) {
                        anchors.right = parent.right;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.pushToCurrent(directthreadpage, PagesConstants.highlight_stories, {
                        highlightId: story_share.reel_id
                    });
                }
            }
        }
    }

    Component {
        id: noStoryShareComponent

        Row {
            Rectangle {
                visible: isOutgoing == false
                width: visible ? units.gu(0.1) : 0
                height: Math.max(parent.height, units.gu(5))
                color: LomiriColors.lightGrey
            }
            Item {
                visible: isOutgoing == false
                width: visible ? units.gu(0.5) : 0
                height: visible ? units.gu(1) : 0
            }

            Column {
                spacing: units.gu(0.1)
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: Helper.formatString(story_share.title)
                    fontSize: "small"
                    color: LomiriColors.darkGrey
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    onLinkActivated: {
                        Scripts.linkClick(directthreadpage, link);
                    }

                    horizontalAlignment: Text.AlignRight
                }

                Label {
                    text: story_share.message
                    fontSize: "small"
                    color: LomiriColors.darkGrey
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap

                    horizontalAlignment: Text.AlignRight
                }
            }

            Item {
                visible: isOutgoing
                width: visible ? units.gu(0.5) : 0
                height: visible ? units.gu(1) : 0
            }
            Rectangle {
                visible: isOutgoing
                width: visible ? units.gu(0.1) : 0
                height: Math.max(parent.height, units.gu(5))
                color: LomiriColors.lightGrey
            }

            Component.onCompleted: {
                if (isOutgoing) {
                    anchors.right = parent.right;
                }
            }
        }
    }

    Rectangle {
        visible: typeof story_share.text != 'undefined' && story_share.text !== ''
        width: typeof story_share.text != 'undefined' && story_share.text !== '' ? myStoryText.width + units.gu(3) : 0
        height: typeof story_share.text != 'undefined' && story_share.text !== '' ? myStoryText.height + units.gu(2.5) : 0
        color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
        radius: units.gu(2)
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

        Label {
            id: myStoryText
            wrapMode: Text.WordWrap
            width: Math.min(myStoryText.implicitWidth, itemMaxWidth)
            anchors.centerIn: parent
            text: typeof story_share.text != 'undefined' && story_share.text !== '' ? story_share.text : ''
        }

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right;
            }
        }
    }
}
