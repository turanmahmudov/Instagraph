// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Helper.js" as Helper

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../viewmodels"

PageItem {
    id: editpagepage

    property var mediaId

    header: PageHeaderItem {
        title: i18n.tr("Edit")
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Done")
                iconName: IconsConstants.checkmark
                enabled: !editMediaViewModel.isSaving
                onTriggered: editMediaViewModel.saveCaption(mediaCaption.text)
            }
        ]
    }

    EditMediaViewModel {
        id: editMediaViewModel
        mediaId: editpagepage.mediaId
        onCaptionChanged: mediaCaption.text = caption
        onMediaSaved: pageLayout.removePages(editpagepage)
    }

    Component.onCompleted: {
        editMediaViewModel.loadMedia();
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
                source: editMediaViewModel.imageCandidates.length > 0 ? Helper.getBestImage(editMediaViewModel.imageCandidates, width).url : ""
            }

            TextArea {
                id: mediaCaption
                width: parent.width - units.gu(9)
                height: units.gu(8)
                placeholderText: i18n.tr("Write a caption...")
            }
        }
    }
}
