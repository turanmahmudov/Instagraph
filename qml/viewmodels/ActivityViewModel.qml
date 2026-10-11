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

    property JsonListModel activityModel: ActivityListModel {}

    property bool isLoading: false
    property bool hasNewNotifications: false

    function loadActivity() {
        isLoading = true;
        activityModel.clear();

        instagram.getRecentActivityInbox();
    }

    Connections {
        target: instagram
        function onRecentActivityInboxDataReady(answer) {
            var data = activityModel.parseResponse(answer, ["friend_request_stories", "new_stories", "old_stories"]);
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

        if (activityModel.countParsed("friend_request_stories") > 0) {
            activityModel.appendParsed("friend_request_stories", true, {
                "friendRequests": true
            });
        } else {
            activityModel.clear();
        }

        if (activityModel.countParsed("new_stories") > 0) {
            hasNewNotifications = true;
        }

        var linkColor = Helper.hexToRgb(styleApp.common.textColor);

        activityModel.appendParsed("new_stories", false, {
            "linkColor": linkColor
        });

        activityModel.appendParsed("old_stories", false, {
            "linkColor": linkColor
        });
    }
}
