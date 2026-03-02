import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: followerspage

    header: PageHeaderItem {
        title: i18n.tr("Followers")
    }

    property var userId

    property alias list_loading: viewModel.isLoading

    BaseUserListViewModel {
        id: viewModel
        hasPagination: true
    }

    ListView {
        id: userFollowersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: followerspage.header.bottom
        }
        model: viewModel.userListModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(followerspage, PagesConstants.user, {usernameId: user.pk})
        }
        onMovementEnded: {
            if (atYEnd && viewModel.canLoadMore()) loadFollowers(viewModel.nextMaxId)
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.userListModel.count === 0
            onRefresh: {
                loadFollowers('')
            }
        }
    }

    function loadFollowers(nextId) {
        viewModel.loadData(nextId, function(nid) {
            instagram.getFollowers(userId, nid)
        })
    }

    Connections {
        target: instagram
        onFollowersDataReady: {
            viewModel.handleResponse(answer)
        }
    }

    Component.onCompleted: {
        loadFollowers()
    }
}
