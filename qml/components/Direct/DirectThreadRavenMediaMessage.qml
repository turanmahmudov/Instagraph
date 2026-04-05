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
    visible: typeof options !== 'undefined' && typeof media !== 'undefined'

    sourceComponent: {
        if (!options || !media)
            return ravenMediaNoVisualComponent;

        var expired = options.raven_media_expired === true;
        var hasImage = media.media && media.media.image_versions2 && media.media.image_versions2.candidates && media.media.image_versions2.candidates.length > 0;

        return (expired || !hasImage) ? ravenMediaNoVisualComponent : ravenMediaImageComponent;
    }

    Component {
        id: ravenMediaImageComponent

        Image {
            width: itemMaxWidth
            height: {
                if (!media || !media.media || !media.media.image_versions2)
                    return itemMaxWidth;
                var candidate = media.media.image_versions2.candidates[0];
                if (!candidate || !candidate.width || !candidate.height)
                    return itemMaxWidth;
                return width / candidate.width * candidate.height;
            }
            source: {
                if (!media || !media.media || !media.media.image_versions2)
                    return "";
                var candidate = media.media.image_versions2.candidates[0];
                return candidate ? (candidate.url || "") : "";
            }
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(width, height)
            smooth: true
            clip: true
        }
    }

    Component {
        id: ravenMediaNoVisualComponent

        Rectangle {
            width: myText.width + units.gu(3)
            height: myText.height + units.gu(2.5)
            color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
            radius: units.gu(2)

            Label {
                id: myText
                wrapMode: Text.WordWrap
                width: Math.min(myText.implicitWidth, itemMaxWidth)
                anchors.centerIn: parent
                text: {
                    if (!media || !media.media)
                        return i18n.tr("Media");
                    return media.media.media_type === 2 ? i18n.tr("Video") : i18n.tr("Photo");
                }
                color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
            }
        }
    }
}
