// Qt imports
import QtQuick 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../viewmodels"

PageItem {
    id: videocaptionpage

    property var videoUrl

    readonly property bool videoReady: player.duration > 0 && videoOutput.sourceRect.width > 0

    header: PageHeaderItem {
        title: i18n.tr("Publish")
        leadingActions: [
            Action {
                text: i18n.tr("Back")
                iconName: IconsConstants.chevron_left
                onTriggered: pageLayout.removePages(videocaptionpage)
            }
        ]
        trailingActions: [
            Action {
                text: i18n.tr("Share")
                iconName: IconsConstants.checkmark
                enabled: videoReady && !publishViewModel.isUploading
                onTriggered: share()
            }
        ]
    }

    PublishViewModel {
        id: publishViewModel
        onPublished: {
            pageLayout.removePages(homePage);
            pageLayout.primaryPage = homePage;

            Scripts.pushSingleImage(pageLayout.primaryPage, mediaId);
        }
    }

    function share() {
        player.pause();

        var width = Math.round(videoOutput.sourceRect.width);
        var height = Math.round(videoOutput.sourceRect.height);
        var coverPath = instagram.photos_path() + "/video_cover_" + Date.now() + ".jpg";

        videoOutput.grabToImage(function (result) {
            if (!result.saveToFile(coverPath)) {
                publishViewModel.errorMessage = i18n.tr("Could not save the video cover.");
                return;
            }
            publishViewModel.publishVideo(videoUrl, coverPath, width, height, player.duration, caption.text, disableCommentsSwitch.checked);
        }, Qt.size(width, height));
    }

    MediaPlayer {
        id: player
        source: videoUrl
        autoPlay: true
        muted: true
        loops: MediaPlayer.Infinite
    }

    Column {
        id: uploadProgressItem
        visible: publishViewModel.isUploading
        anchors.top: videocaptionpage.header.bottom
        width: parent.width

        Rectangle {
            width: parent.width
            height: units.gu(5)
            color: Qt.lighter(LomiriColors.lightGrey, 1.2)

            Label {
                anchors.left: parent.left
                anchors.leftMargin: units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                text: publishViewModel.progress >= 100 ? i18n.tr("Saving") : i18n.tr("Posting")
            }
        }

        ProgressBar {
            width: parent.width
            minimumValue: 0
            maximumValue: 100
            value: publishViewModel.progress
        }
    }

    Flickable {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: publishViewModel.isUploading ? uploadProgressItem.bottom : videocaptionpage.header.bottom
        }
        contentHeight: contentColumn.height
        clip: true

        Column {
            id: contentColumn
            width: parent.width
            spacing: units.gu(1)

            VideoOutput {
                id: videoOutput
                width: parent.width
                height: sourceRect.width > 0 ? width * sourceRect.height / sourceRect.width : width
                source: player
                fillMode: VideoOutput.PreserveAspectFit
            }

            Label {
                visible: text.length > 0
                width: parent.width - units.gu(2)
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                color: LomiriColors.red
                text: publishViewModel.errorMessage
            }

            TextArea {
                id: caption
                width: parent.width - units.gu(2)
                height: units.gu(8)
                anchors.horizontalCenter: parent.horizontalCenter
                placeholderText: i18n.tr("Write a caption...")
            }

            ListItem {
                height: disableCommentsLayout.height
                divider.visible: false

                ListItemLayout {
                    id: disableCommentsLayout
                    title.text: i18n.tr("Turn off commenting")

                    Switch {
                        id: disableCommentsSwitch
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: false
                    }
                }
            }
        }
    }
}
