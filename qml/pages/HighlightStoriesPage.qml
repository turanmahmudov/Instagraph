// Qt imports
import QtQuick 2.12

// JavaScript imports
import "../js/Helper.js" as Helper

// Component imports
import "../components/Constants"
import "../components/Stories"

StoryViewerPage {
    id: highlightStoriesPage

    property var highlightId
    property var allHighlights: []

    // Bind navigation context
    currentEntryId: highlightId
    allEntries: allHighlights

    // Internal references
    property var user
    property var highlight: {
        'title': '',
        'cover_url': ''
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    function getReelsMediaFeed() {
        var idsArray = []
        idsArray.push(highlightId)
        instagram.getReelsMediaFeed(JSON.stringify(idsArray));
    }

    function handleReelsData(data) {
        if (!data || !data.reels || !data.reels[highlightId]) {
            storyUnavailable = true
            getting = false
            return
        }

        var reelData = data.reels[highlightId]
        var items = reelData.items

        if (!items || items.length === 0) {
            // Show highlight info in header even when unavailable
            user = reelData.user
            if (user) {
                highlight = {
                    'title': "title" in reelData ? reelData.title : user.username,
                    'cover_url': "cover_media" in reelData ? reelData.cover_media.cropped_image_version.url : user.profile_pic_url
                }
                headerImageSource = highlight.cover_url
                headerTitle = highlight.title
                headerSubtitle = ""
            }
            storyUnavailable = true
            getting = false
            return
        }

        storyUnavailable = false

        worker.sendMessage({'feed': 'userStoriesPage', 'obj': items, 'model': storiesModel, 'clear_model': true})

        user = reelData.user
        highlight = {
            'title': "title" in reelData ? reelData.title : (user ? user.username : ""),
            'cover_url': "cover_media" in reelData ? reelData.cover_media.cropped_image_version.url : (user ? user.profile_pic_url : "")
        }

        // Update header
        headerImageSource = highlight.cover_url
        headerTitle = highlight.title
        headerSubtitle = Helper.milisecondsToString(items[0].taken_at, true)

        // Mark all stories as seen immediately
        markStoriesSeen(items)

        getting = false
    }

    Component.onCompleted: {
        getReelsMediaFeed()
    }

    onRequestLoadEntry: {
        highlightId = entryId
        getReelsMediaFeed()
    }

    onHeaderClicked: {
        if (user) {
            pageLayout.pushToCurrent(highlightStoriesPage, PagesConstants.user, {usernameId: user.pk})
        }
    }

    Connections {
        target: instagram
        onReelsMediaFeedDataReady: {
            var data = JSON.parse(answer)
            handleReelsData(data)
        }
        onMarkStoryMediaSeenDataReady: {
        }
    }
}
