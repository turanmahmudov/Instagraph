import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Page"
import "../components/Activity"

import "../js/Helper.js" as Helper

PageItem {
    id: activitypage

    header: PageHeaderItem {
        title: i18n.tr("Activity")
        noBackAction: true
    }

    property bool new_notifs: false

    property bool list_loading: false

    property bool isPullToRefresh: true

    ListModel {
        id: recentActivityModel
    }

    Loader {
        id: viewLoader
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: activitypage.header.bottom
        }
        active: true
        sourceComponent: recentActivityComponent
    }

    Component {
        id: recentActivityComponent

        ListView {
            id: recentActivityList
            anchors.fill: parent

            clip: true
            cacheBuffer: activitypage.height
            model: recentActivityModel
            delegate: ListItem {
                divider.visible: false
                height: calculateHeight(list_type)

                function calculateHeight(list_type) {
                    if (list_type === 'follow_requests') {
                        return followRequestsLoader.height;
                    }
                    if (list_type === 'recent_activity') {
                        return recentActivityLoader.height;
                    }
                    return 0;
                }

                Loader {
                    id: followRequestsLoader
                    width: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    visible: list_type === 'follow_requests'
                    active: visible
                    asynchronous: true

                    sourceComponent: FollowRequest {
                        width: parent.width
                    }
                }

                Loader {
                    id: recentActivityLoader
                    width: parent.width
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    visible: list_type === 'recent_activity'
                    active: visible
                    asynchronous: false

                    sourceComponent: RecentActivity {
                        width: parent.width
                    }
                }
            }
            PullToRefresh {
                refreshing: list_loading && recentActivityModel.count === 0
                onRefresh: {
                    isPullToRefresh = true;
                    getRecentActivity();
                }
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }

    WorkerScript {
        id: worker
        source: "../js/Workers/ActivityWorker.js"
    }

    Connections {
        target: instagram
        onRecentActivityInboxDataReady: {
            var data = JSON.parse(answer);
            recentActivityDataFinished(data);
        }
    }

    function getRecentActivity() {
        recentActivityModel.clear();
        instagram.getRecentActivityInbox();
    }

    function recentActivityDataFinished(data) {
        if (!data)
            return;
        isPullToRefresh = false;

        // Follow Requests
        if ("friend_request_stories" in data && data.friend_request_stories.length > 0) {
            worker.sendMessage({
                friend_requests: data.friend_request_stories,
                model: recentActivityModel,
                clear: true
            });
        } else {
            recentActivityModel.clear();
        }

        // New activity stories
        if ("new_stories" in data && data.new_stories.length > 0) {
            new_notifs = true;
        }

        let linkColor = Helper.hexToRgb(styleApp.common.textColor);

        // New stories
        worker.sendMessage({
            items: data.new_stories,
            model: recentActivityModel,
            partition: data.partition,
            clear: false,
            linkColor: linkColor
        });

        // Old stories
        worker.sendMessage({
            items: data.old_stories,
            model: recentActivityModel,
            partition: data.partition,
            clear: false,
            linkColor: linkColor
        });

        list_loading = false;
    }
}
