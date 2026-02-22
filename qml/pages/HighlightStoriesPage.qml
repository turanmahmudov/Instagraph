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
        onMessage: {
        }
    }

    function getReelsMediaFeed() {
        var idsArray = []
        idsArray.push(highlightId)
        instagram.getReelsMediaFeed(JSON.stringify(idsArray));
    }

    function handleReelsData(data) {
        if (!data || !data.reels || !data.reels[highlightId]) {
            return
        }

        var reelData = data.reels[highlightId]
        var items = reelData.items

        if (!items || items.length === 0) {
            return
        }

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
