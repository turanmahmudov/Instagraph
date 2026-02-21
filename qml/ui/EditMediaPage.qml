// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.1

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: editpagepage

    property var mediaId

    header: PageHeaderItem {
        title: i18n.tr("Edit")
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Done")
                iconName: IconsConstants.camera_flip
                onTriggered: {
                    instagram.editMedia(mediaId, mediaCaption.text)
                }
            }

        ]
    }

    function mediaDataFinished(data) {
        mediaImage.source = Helper.getBestImage(data.items[0].image_versions2.candidates, mediaImage.width).url;
        mediaCaption.text = data.items[0].caption.text;
    }

    function mediaEditFinished(data) {
        if (data.status == 'ok') {
            pageStack.pop();
            Scripts.pushSingleImage(editpagepage, mediaId)
        }
    }

    Component.onCompleted: {
        instagram.infoMedia(mediaId);
    }

    Column {
        width: parent.width
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            top: editpagepage.header.bottom
            topMargin: units.gu(1)
        }

        Row {
            width: parent.width
            spacing: units.gu(1)

            Image {
                id: mediaImage
                width: units.gu(8)
                height: width
                smooth: true
                cache: false
                clip: true
                fillMode: Image.PreserveAspectFit
            }

            TextArea {
                id: mediaCaption
                width: parent.width - units.gu(9)
                height: units.gu(8)
                placeholderText: i18n.tr("Write a caption...")
            }
        }
    }

    Connections{
        target: instagram
        onMediaInfoReady: {
            var data = JSON.parse(answer);
            mediaDataFinished(data)
        }
        onMediaEdited: {
            var data = JSON.parse(answer);
            mediaEditFinished(data);
        }
    }
}
