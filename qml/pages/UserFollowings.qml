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

    FollowingsViewModel {
        id: viewModel
        userId: followingspage.userId
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
                viewModel.load(viewModel.nextMaxId);
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.userListModel.count === 0
            onRefresh: {
                viewModel.load('');
            }
        }
    }

    Component.onCompleted: {
        viewModel.load();
    }
}
