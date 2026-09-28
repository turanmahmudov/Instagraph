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
    id: publishpage

    property string mediaUrl
    property bool isVideo: false

    readonly property int captionLimit: 2200

    property var selectedLocation: null

    readonly property bool mediaReady: !isVideo || (player.duration > 0 && videoPreview.sourceRect.width > 0)
    readonly property bool canShare: mediaReady && !publishViewModel.isUploading && captionField.length <= captionLimit

    header: PageHeaderItem {
        title: isVideo ? i18n.tr("New Video") : i18n.tr("New Photo")
        trailingActions: [
            Action {
                text: i18n.tr("Share")
                iconName: IconsConstants.checkmark
                enabled: canShare
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

    LocationSearchViewModel {
        id: locationViewModel
    }

    Component.onCompleted: {
        locationViewModel.search();
    }

    Connections {
        target: mainView
        function onLocationSelected(location) {
            selectedLocation = location;
        }
    }

    function share() {
        var location = selectedLocation || {};

        if (!isVideo) {
            publishViewModel.publish(mediaUrl, captionField.text, location, commentsSwitch.checked);
            return;
        }

        player.pause();

        var width = Math.round(videoPreview.sourceRect.width);
        var height = Math.round(videoPreview.sourceRect.height);
        var coverPath = instagram.photos_path() + "/video_cover_" + Date.now() + ".jpg";

        videoPreview.grabToImage(function (result) {
            if (!result.saveToFile(coverPath)) {
                publishViewModel.errorMessage = i18n.tr("Could not save the video cover.");
                return;
            }
            publishViewModel.publishVideo(mediaUrl, coverPath, width, height, player.duration, captionField.text, location, commentsSwitch.checked);
        }, Qt.size(width, height));
    }

    function chooseLocation(place) {
        selectedLocation = {
            "name": place.name.replace("&", "%26"),
            "address": place.address.replace("&", "%26"),
            "lat": place.lat.toFixed(4),
            "lng": place.lng.toFixed(4),
            "external_id": place.external_id,
            "external_id_source": place.external_id_source
        };
    }

    MediaPlayer {
        id: player
        source: isVideo ? mediaUrl : ""
        autoPlay: isVideo
        muted: true
        loops: MediaPlayer.Infinite
    }

    Column {
        id: uploadStatus
        visible: publishViewModel.isUploading
        anchors.top: publishpage.header.bottom
        width: parent.width

        ProgressBar {
            width: parent.width
            minimumValue: 0
            maximumValue: 100
            value: publishViewModel.progress
            indeterminate: publishViewModel.progress >= 100
        }

        Label {
            x: units.gu(2)
            height: units.gu(4)
            verticalAlignment: Text.AlignVCenter
            fontSize: "small"
            color: styleApp.common.text2Color
            text: publishViewModel.progress >= 100 ? i18n.tr("Processing…") : i18n.tr("Uploading %1%").arg(Math.round(publishViewModel.progress))
        }
    }

    Flickable {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: publishViewModel.isUploading ? uploadStatus.bottom : publishpage.header.bottom
        }
        contentHeight: form.height + units.gu(4)
        clip: true
        interactive: contentHeight > height

        Column {
            id: form
            width: parent.width
            enabled: !publishViewModel.isUploading
            opacity: enabled ? 1.0 : 0.5

            Label {
                id: errorLabel
                visible: text.length > 0
                x: units.gu(2)
                width: parent.width - units.gu(4)
                height: visible ? implicitHeight + units.gu(1.5) : 0
                verticalAlignment: Text.AlignBottom
                wrapMode: Text.WordWrap
                color: LomiriColors.red
                text: publishViewModel.errorMessage
            }

            Item {
                width: parent.width
                height: Math.max(previewBox.height, captionColumn.height) + units.gu(3)

                Rectangle {
                    id: previewBox
                    x: units.gu(2)
                    y: units.gu(1.5)
                    width: units.gu(12)
                    height: width
                    color: "#000000"
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: !isVideo
                        source: isVideo ? "" : mediaUrl
                        autoTransform: true
                        asynchronous: true
                        cache: false
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 512
                        sourceSize.height: 512
                    }

                    VideoOutput {
                        id: videoPreview
                        visible: isVideo
                        anchors.centerIn: parent
                        width: sourceRect.width >= sourceRect.height || sourceRect.height === 0 ? parent.width : parent.height * sourceRect.width / sourceRect.height
                        height: sourceRect.width < sourceRect.height || sourceRect.width === 0 ? parent.height : parent.width * sourceRect.height / sourceRect.width
                        source: player
                        fillMode: VideoOutput.Stretch
                    }

                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: isVideo && !mediaReady
                    }
                }

                Column {
                    id: captionColumn
                    anchors {
                        left: previewBox.right
                        leftMargin: units.gu(1.5)
                        right: parent.right
                        rightMargin: units.gu(2)
                        top: previewBox.top
                    }
                    spacing: units.gu(0.5)

                    TextArea {
                        id: captionField
                        width: parent.width
                        autoSize: true
                        maximumLineCount: 8
                        placeholderText: i18n.tr("Write a caption…")
                    }

                    Label {
                        visible: captionField.length > captionLimit - 200
                        anchors.right: parent.right
                        fontSize: "x-small"
                        color: captionField.length > captionLimit ? LomiriColors.red : styleApp.common.text2Color
                        text: "%1 / %2".arg(captionField.length).arg(captionLimit)
                    }
                }
            }

            MentionSuggestions {
                width: parent.width
                field: captionField
            }

            ListItem {
                height: locationLayout.height
                divider.visible: true
                onClicked: pageLayout.pushToCurrent(publishpage, PagesConstants.search_location)

                ListItemLayout {
                    id: locationLayout
                    title.text: selectedLocation ? selectedLocation.name.replace("%26", "&") : i18n.tr("Add location")
                    title.color: selectedLocation ? styleApp.common.textColor : styleApp.common.text2Color

                    LineIcon {
                        name: ""
                        iconSize: units.gu(2)
                        SlotsLayout.position: SlotsLayout.Leading
                    }

                    AbstractButton {
                        visible: selectedLocation !== null
                        width: units.gu(4)
                        height: width
                        SlotsLayout.position: SlotsLayout.Trailing
                        onClicked: selectedLocation = null

                        LineIcon {
                            anchors.centerIn: parent
                            name: IconsConstants.close
                            iconSize: units.gu(1.8)
                        }
                    }
                }
            }

            ListView {
                visible: selectedLocation === null && count > 0
                x: units.gu(2)
                width: parent.width - units.gu(2)
                height: visible ? units.gu(6) : 0
                orientation: ListView.Horizontal
                spacing: units.gu(1)
                clip: true
                model: locationViewModel.placesModel

                delegate: AbstractButton {
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    width: chipLabel.width + units.gu(3)
                    height: units.gu(3.5)
                    onClicked: chooseLocation(model)

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: "transparent"
                        border.width: units.dp(1)
                        border.color: styleApp.common.outlineButtonBorderColor
                    }

                    Label {
                        id: chipLabel
                        anchors.centerIn: parent
                        text: name
                        fontSize: "small"
                        color: styleApp.common.textColor
                    }
                }
            }

            ListItem {
                height: commentsLayout.height
                divider.visible: false

                ListItemLayout {
                    id: commentsLayout
                    title.text: i18n.tr("Turn off commenting")

                    Switch {
                        id: commentsSwitch
                        SlotsLayout.position: SlotsLayout.Trailing
                        checked: false
                    }
                }
            }
        }
    }
}
