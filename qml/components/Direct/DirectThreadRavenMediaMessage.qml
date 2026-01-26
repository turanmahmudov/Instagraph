import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Feed"

import "../../js/Helper.js" as Helper

Loader {
    property bool isOutgoing: false
    property var itemMaxWidth

    active: true
    sourceComponent: options.raven_media_expired === true 
        ? ravenMediaNoVisualComponent
        : ravenMediaImageComponent

    Component {
        id: ravenMediaImageComponent

        Image {
            width: itemMaxWidth
            height: width / media.media.image_versions2.candidates[0].width * media.media.image_versions2.candidates[0].height
            source: media.media.image_versions2.candidates[0].url
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width,height)
            smooth: true
            clip: true
        }
    }
    Component {
        id: ravenMediaNoVisualComponent

        Rectangle {
            width: myText.width + units.gu(3)
            height: myText.height + units.gu(2.5)
            color: isOutgoing
                ? styleApp.directInbox.outgoingMessageBackgroundColor
                : styleApp.directInbox.incomingMessageBackgroundColor
            radius: units.gu(2)

            Label {
                id: myText
                wrapMode: Text.WordWrap
                width: Math.min(myText.implicitWidth, itemMaxWidth)
                anchors.centerIn: parent
                text: media.media.media_type === 2 
                    ? i18n.tr("Video") 
                    : i18n.tr("Photo")
                color: isOutgoing 
                    ? styleApp.directInbox.outgoingMessageTextColor
                    : styleApp.directInbox.incomingMessageTextColor
            }
        }
    }
}
