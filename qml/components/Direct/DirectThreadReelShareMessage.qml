import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."

Column {
    property bool isOutgoing: false
    property var itemMaxWidth
    property var itemSmallWidth

    spacing: units.gu(0.4)
    anchors.verticalCenter: parent.verticalCenter

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
                text: reel_share.type === 'mention'
                    ? (isOutgoing ? i18n.tr("You mentioned their in a story") : i18n.tr("Mentied you in a story"))
                    : reel_share.type === ''
                        ? (isOutgoing ? i18n.tr("You replied to their story") : i18n.tr("Replied to your story"))
                        : i18n.tr("UNKNOWN")
                fontSize: "small"
                color: LomiriColors.darkGrey
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                width: contentWidth

                horizontalAlignment: Text.AlignRight
            }

            Loader {
                active: typeof reel_share.media.image_versions2 != 'undefined'
                sourceComponent: Image {
                    width: itemSmallWidth
                    height: width/reel_share.media.image_versions2.candidates[0].width*reel_share.media.image_versions2.candidates[0].height
                    source: reel_share.media.image_versions2.candidates[0].url
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    clip: true
                }

                Component.onCompleted: {
                    if (isOutgoing) {
                        anchors.right = parent.right
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
                anchors.right = parent.right
            }
        }
    }

    Rectangle {
        visible: typeof reel_share.text != 'undefined' && reel_share.text !== ''
        width: typeof reel_share.text != 'undefined' && reel_share.text !== '' ? myReelText.width + units.gu(3) : 0
        height: typeof reel_share.text != 'undefined' && reel_share.text !== '' ? myReelText.height + units.gu(2.5) : 0
        color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
        radius: units.gu(2)
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

        Label {
            id: myReelText
            wrapMode: Text.WordWrap
            width: Math.min(myReelText.implicitWidth, itemMaxWidth)
            anchors.centerIn: parent
            text: typeof reel_share.text != 'undefined' && reel_share.text !== '' ? reel_share.text : ''
        }

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right
            }
        }
    }
}
