import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/Activity"
import "../viewmodels"

PageItem {
    id: activitypage

    header: PageHeaderItem {
        title: i18n.tr("Activity")
        noBackAction: true
    }

    ActivityViewModel {
        id: viewModel
    }

    property alias new_notifs: viewModel.hasNewNotifications
    property alias list_loading: viewModel.isLoading

    function getRecentActivity() {
        viewModel.loadActivity();
    }

    ListView {
        id: recentActivityList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: activitypage.header.bottom
        }

        clip: true
        cacheBuffer: activitypage.height
        model: viewModel.activityModel
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
                    onClicked: pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.follow_requests)
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
            refreshing: viewModel.isLoading && viewModel.activityModel.count === 0
            onRefresh: {
                getRecentActivity();
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
