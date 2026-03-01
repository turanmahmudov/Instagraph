// Qt imports
import QtQuick 2.12

// JavaScript imports
import "../js/Helper.js" as Helper

// Component imports
import "../components/Constants"
import "../components/Stories"

StoryViewerPage {
    id: userStoriesPage

    property var userId
    property var allUsers: []

    // Bind navigation context
    currentEntryId: userId
    allEntries: allUsers

    // Internal user reference for header navigation
    property var user

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
        onMessage: {
        }
    }

    function getUserReelsMediaFeed() {
        instagram.getUserReelsMediaFeed(userId);
    }

    function handleReelsData(data) {
        if (!data || !data.items || data.items.length === 0) {
            // Show user info in header even when story is unavailable
            if (data && data.user) {
                user = data.user
                headerImageSource = data.user.profile_pic_url || ""
                headerTitle = data.user.username || ""
                headerSubtitle = ""
            }
            storyUnavailable = true
            getting = false
            return
        }

        storyUnavailable = false

        worker.sendMessage({'feed': 'userStoriesPage', 'obj': data.items, 'model': storiesModel, 'clear_model': true})

        user = data.user

        // Update header with user info
        headerImageSource = data.user ? data.user.profile_pic_url : ""
        headerTitle = data.user ? data.user.username : ""
        headerSubtitle = Helper.milisecondsToString(data.items[0].taken_at, true)

        // Mark all stories as seen immediately
        markStoriesSeen(data.items)

        getting = false
    }

    Component.onCompleted: {
        getUserReelsMediaFeed()
    }

    onRequestLoadEntry: {
        userId = entryId
        getUserReelsMediaFeed()
    }

    onHeaderClicked: {
        if (user) {
            pageLayout.pushToCurrent(userStoriesPage, PagesConstants.user, {usernameId: user.pk})
        }
    }

    Connections {
        target: instagram
        onUserReelsMediaFeedDataReady: {
            var data = JSON.parse(answer)
            handleReelsData(data)
        }
        onMarkStoryMediaSeenDataReady: {
        }
    }
}
