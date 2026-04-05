import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: followingspage

    header: PageHeaderItem {
        title: i18n.tr("Followings")
    }

    property var userId

    property alias list_loading: viewModel.isLoading

    BaseUserListViewModel {
        id: viewModel
        hasPagination: true
    }

    ListView {
        id: userFollowingsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: followingspage.header.bottom
        }
        model: viewModel.userListModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(followingspage, PagesConstants.user, {
                usernameId: user.pk
            })
        }
        onMovementEnded: {
            if (atYEnd && viewModel.canLoadMore())
                loadFollowings(viewModel.nextMaxId);
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.userListModel.count === 0
            onRefresh: {
                loadFollowings('');
            }
        }
    }

    function loadFollowings(nextId) {
        viewModel.loadData(nextId, function (nid) {
            instagram.getFollowing(userId, nid);
        });
    }

    Connections {
        target: instagram
        onFollowingDataReady: {
            viewModel.handleResponse(answer);
        }
    }

    Component.onCompleted: {
        loadFollowings();
    }
}
