// Qt imports
import QtQuick 2.12
import QtGraphicalEffects 1.0
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../../js/Helper.js" as Helper

// Component imports
import ".."
import "../Constants"
import "../Page"

PageItem {
    id: storyViewerPage

    // -- Public API: must be set by the instantiating page --
    property string headerImageSource: ""
    property string headerTitle: ""
    property string headerSubtitle: ""  // e.g. time ago

    // Navigation context
    property var allEntries: []         // array of user PKs or highlight IDs
    property var currentEntryId         // current user PK or highlight ID

    // Callback: the parent page must implement these
    // Called when we need to load the next/prev entry
    signal requestLoadEntry(var entryId)
    // Called when user taps on the header avatar/name
    signal headerClicked

    // -- Internal state --
    property int progressTime: 0
    property bool getting: false
    property bool paused: false
    property bool storyUnavailable: false
    property int _remainingTime: 0  // remaining ms when paused

    // The parent page populates this model via the worker
    property alias storiesModel: storiesModel
    property alias storiesList: storiesList

    header: PageHeaderItem {
        whiteIcons: true
        StyleHints {
            backgroundColor: "transparent"
            foregroundColor: "#ffffff"
            dividerColor: "transparent"
        }
        contents: Rectangle {
            anchors.fill: parent
            color: "transparent"

            Row {
                spacing: units.gu(1)
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Item {
                    width: units.gu(4)
                    height: width

                    CircleImage {
                        id: headerProfileImage
                        width: parent.width
                        height: width
                        source: headerImageSource || "../../images/not_found_user.jpg"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: headerClicked()
                    }
                }

                Label {
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: headerTitle
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: "#ffffff"
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: headerClicked()
                    }
                }

                Label {
                    id: timeAgoLabel
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    text: headerSubtitle
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap
                    color: Qt.lighter(LomiriColors.lightGrey, 1.1)
                    layer.enabled: true
                    layer.effect: DropShadow {
                        verticalOffset: 2
                        horizontalOffset: 2
                        spread: 0.4
                    }
                }
            }
        }
    }

    // -- Timers --

    Timer {
        id: storyTimer
        interval: 4000
        running: false
        repeat: false
        onTriggered: {
            storiesList.nextSlide();
        }
    }

    Timer {
        id: progressTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            progressTime += 100;
        }
    }

    // Start a new story timer (resets progress)
    function startNewStoryTimer(durationMs) {
        storyTimer.stop();
        progressTimer.stop();
        progressTime = 0;
        _remainingTime = 0;
        storyTimer.interval = durationMs;
        storyTimer.start();
        progressTimer.start();
    }

    // -- Pause / Resume helpers --

    function pauseStory() {
        if (storyTimer.running) {
            paused = true;
            // Calculate remaining time based on elapsed progress
            _remainingTime = storyTimer.interval - progressTime;
            if (_remainingTime < 0)
                _remainingTime = 0;
            storyTimer.stop();
            progressTimer.stop();
        }
    }

    function resumeStory() {
        if (paused) {
            paused = false;
            // Resume with the remaining time
            storyTimer.interval = _remainingTime > 0 ? _remainingTime : 100;
            storyTimer.start();
            progressTimer.start();
        }
    }

    // -- Mark stories as seen --

    function markStoriesSeen(items) {
        if (!items || items.length === 0)
            return;
        var reels = {};
        var now = new Date().getTime();

        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var itemTakenAt = item.taken_at;
            var seenAt = now;
            if (seenAt < itemTakenAt) {
                seenAt = itemTakenAt + 2;
            }

            var itemSourceId = item.user.pk;
            var reelId = item.id + '_' + itemSourceId;
            reels[reelId] = [itemTakenAt + '_' + seenAt];
        }

        instagram.markStoryMediaSeen(JSON.stringify(reels));
    }

    // Update the time-ago label for the current slide
    function updateTimeAgo() {
        if (storiesModel.count > 0 && storiesList.currentIndex >= 0 && storiesList.currentIndex < storiesModel.count) {
            headerSubtitle = Helper.milisecondsToString(storiesModel.get(storiesList.currentIndex).taken_at, true);
        }
    }

    // -- Progress bar row --

    Row {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            topMargin: units.gu(0.3)
        }
        z: 100
        spacing: units.gu(0.5)

        Repeater {
            id: progressRepeater
            model: storiesModel.count

            ProgressBar {
                property real maxValue: {
                    var item = storiesModel.get(index);
                    if (item && typeof item.video_duration !== 'undefined' && item.video_duration !== 0) {
                        return item.video_duration * 1000;
                    }
                    return 4000;
                }

                width: (parent.width - (storiesModel.count - 1) * units.gu(0.5)) / storiesModel.count
                value: index === storiesList.currentIndex ? (getting ? maxValue : progressTime) : (index < storiesList.currentIndex ? maxValue : 0)
                minimumValue: 0
                maximumValue: maxValue
            }
        }
    }

    // -- Story model & list --

    ListModel {
        id: storiesModel
    }

    ListView {
        id: storiesList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        snapMode: ListView.SnapOneItem
        orientation: Qt.Horizontal
        highlightMoveDuration: LomiriAnimation.FastDuration
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true
        clip: true
        interactive: false

        model: storiesModel
        delegate: Item {
            id: storyDelegate
            width: storyViewerPage.width
            height: {
                if (typeof image_versions2 !== 'undefined' && image_versions2.candidates && image_versions2.candidates[0]) {
                    return width / image_versions2.candidates[0].width * image_versions2.candidates[0].height;
                }
                return storyViewerPage.height;
            }

            Loader {
                id: mediaLoader
                anchors.fill: parent
                asynchronous: false
                active: storiesList.currentIndex === index
                sourceComponent: media_type === 2 ? storyVideoComponent : storyImageComponent
            }

            Component {
                id: storyImageComponent

                Item {
                    anchors.fill: parent

                    Image {
                        id: storyImage
                        width: parent.width
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        source: image_versions2.candidates[0].url
                        sourceSize: Qt.size(width, height)
                        smooth: true

                        onStatusChanged: {
                            if (status === Image.Ready) {
                                startNewStoryTimer(4000);
                            }
                        }
                    }

                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: storyImage.status === Image.Loading
                        visible: running
                    }
                }
            }

            Component {
                id: storyVideoComponent

                Item {
                    id: videoContainer
                    anchors.fill: parent

                    property bool timerStarted: false

                    MediaPlayer {
                        id: player
                        source: video_url
                        autoLoad: true
                        autoPlay: true

                        onPlaybackStateChanged: {
                            if (playbackState === MediaPlayer.PlayingState && !videoContainer.timerStarted) {
                                videoContainer.timerStarted = true;
                                startNewStoryTimer(video_duration * 1000);
                            }
                        }

                        onPositionChanged: {
                            if (playbackState === MediaPlayer.PlayingState && !paused) {
                                progressTime = position;
                            }
                        }
                    }

                    VideoOutput {
                        id: videoOutput
                        source: player
                        fillMode: VideoOutput.PreserveAspectCrop
                        anchors.fill: parent
                    }

                    ActivityIndicator {
                        anchors.centerIn: parent
                        running: player.playbackState !== MediaPlayer.PlayingState && player.status !== MediaPlayer.EndOfMedia
                        visible: running
                    }

                    Component.onDestruction: {
                        player.stop();
                    }

                    Connections {
                        target: storyViewerPage
                        function onPausedChanged() {
                            if (storiesList.currentIndex === index) {
                                if (paused) {
                                    player.pause();
                                } else {
                                    player.play();
                                }
                            }
                        }
                    }
                }
            }

            // Tap areas: left third for previous, right two-thirds for next
            // Long press to pause
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (mouse.x < parent.width / 3) {
                        storiesList.previousSlide();
                    } else {
                        storiesList.nextSlide();
                    }
                }

                onPressAndHold: {
                    pauseStory();
                }

                onReleased: {
                    resumeStory();
                }
            }
        }

        onCurrentIndexChanged: {
            updateTimeAgo();
        }

        // Go to next slide, if possible
        function nextSlide() {
            if (currentIndex < model.count - 1) {
                currentIndex++;
            } else {
                // Try to advance to the next entry (next user or next highlight)
                var currentPos = allEntries.indexOf(currentEntryId);
                if (currentPos !== -1 && currentPos < allEntries.length - 1) {
                    currentEntryId = allEntries[currentPos + 1];
                    getting = true;
                    storyTimer.stop();
                    requestLoadEntry(currentEntryId);
                }
            }
        }

        // Go to previous slide, if possible
        function previousSlide() {
            if (currentIndex > 0) {
                currentIndex--;
            } else {
                // Try to go to the previous entry
                var currentPos = allEntries.indexOf(currentEntryId);
                if (currentPos > 0) {
                    currentEntryId = allEntries[currentPos - 1];
                    getting = true;
                    storyTimer.stop();
                    requestLoadEntry(currentEntryId);
                }
            }
        }
    }

    // -- Story unavailable message --
    Label {
        anchors.centerIn: parent
        visible: storyUnavailable
        text: i18n.tr("Story unavailable")
        fontSize: "large"
        font.weight: Font.DemiBold
        color: styleApp.common.textColor
    }
}
