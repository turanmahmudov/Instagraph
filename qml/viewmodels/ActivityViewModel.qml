import QtQuick 2.12
import Instagram 1.0

import "../js/Helper.js" as Helper

/**
 * ActivityViewModel - ViewModel for ActivityPage
 *
 * Handles recent activity loading logic:
 * - Follow requests header
 * - New and old activity stories
 * - New notifications flag
 */
Item {
    id: viewModel
    visible: false

    property ListModel activityModel: ListModel {}

    property bool isLoading: false
    property bool hasNewNotifications: false

    function loadActivity() {
        isLoading = true;
        activityModel.clear();

        instagram.getRecentActivityInbox();
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/ActivityWorker.js"
    }

    Connections {
        target: instagram
        function onRecentActivityInboxDataReady(answer) {
            var data = JSON.parse(answer);
            handleActivityResponse(data);
        }
    }

    /**
     * Process recent activity response from API
     * @param data - Parsed JSON response
     */
    function handleActivityResponse(data) {
        isLoading = false;

        if (!data)
            return;

        if ("friend_request_stories" in data && data.friend_request_stories.length > 0) {
            worker.sendMessage({
                friend_requests: data.friend_request_stories,
                items: [],
                model: activityModel,
                clear: true
            });
        } else {
            activityModel.clear();
        }

        if ("new_stories" in data && data.new_stories.length > 0) {
            hasNewNotifications = true;
        }

        var linkColor = Helper.hexToRgb(styleApp.common.textColor);

        worker.sendMessage({
            items: data.new_stories || [],
            model: activityModel,
            partition: data.partition,
            clear: false,
            linkColor: linkColor
        });

        worker.sendMessage({
            items: data.old_stories || [],
            model: activityModel,
            partition: data.partition,
            clear: false,
            linkColor: linkColor
        });
    }
}
