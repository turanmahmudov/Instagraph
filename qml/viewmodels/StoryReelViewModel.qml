import QtQuick 2.12
import Instagram 1.0

/**
 * StoryReelViewModel - ViewModel for UserStoriesPage and HighlightStoriesPage
 *
 * Handles one story reel at a time:
 * - User reel or highlight reel loading
 * - Marking the loaded stories as seen
 */
Item {
    id: viewModel
    visible: false

    property ListModel storiesModel: ListModel {}

    property var user: null
    property string title: ""
    property string coverUrl: ""
    property var firstTakenAt: null
    property bool unavailable: false

    property bool isLoading: false
    property bool highlightReel: false
    property var pendingReelId: null

    signal reelLoaded

    function loadUserReel(userId) {
        pendingReelId = userId;
        highlightReel = false;
        isLoading = true;
        instagram.getUserReelsMediaFeed(userId);
    }

    function loadHighlightReel(highlightId) {
        pendingReelId = highlightId;
        highlightReel = true;
        isLoading = true;
        instagram.getReelsMediaFeed(JSON.stringify([highlightId]));
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/TimelineWorker.js"
    }

    Connections {
        target: instagram
        function onUserReelsMediaFeedDataReady(answer) {
            if (!isLoading || highlightReel) {
                return;
            }

            var data = JSON.parse(answer);
            if (!data) {
                finishReel(null, null, null);
                return;
            }

            var header = data.user ? {
                "title": data.user.username || "",
                "cover": data.user.profile_pic_url || ""
            } : null;
            finishReel(data.user, header, data.items);
        }
        function onReelsMediaFeedDataReady(answer) {
            if (!isLoading || !highlightReel) {
                return;
            }

            var data = JSON.parse(answer);
            var reel = data && data.reels ? data.reels[pendingReelId] : null;
            if (!reel) {
                finishReel(null, null, null);
                return;
            }

            var reelUser = reel.user;
            var hasItems = reel.items && reel.items.length > 0;
            var header = hasItems || reelUser ? {
                "title": "title" in reel ? reel.title : (reelUser ? reelUser.username : ""),
                "cover": "cover_media" in reel ? reel.cover_media.cropped_image_version.url : (reelUser ? reelUser.profile_pic_url : "")
            } : null;
            finishReel(reelUser, header, reel.items);
        }
    }

    function finishReel(reelUser, header, items) {
        isLoading = false;

        if (reelUser) {
            user = reelUser;
        }
        if (header) {
            title = header.title;
            coverUrl = header.cover;
        }

        if (!items || items.length === 0) {
            unavailable = true;
            firstTakenAt = null;
            reelLoaded();
            return;
        }

        unavailable = false;
        firstTakenAt = items[0].taken_at;

        worker.sendMessage({
            'feed': 'userStoriesPage',
            'obj': items,
            'model': storiesModel,
            'clear_model': true
        });

        markStoriesSeen(items);
        reelLoaded();
    }

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
}
