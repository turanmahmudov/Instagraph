import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: blockeduserspage

    header: PageHeaderItem {
        title: i18n.tr("Blocked Users")
    }

    property alias list_loading: viewModel.isLoading

    BlockedUsersViewModel {
        id: viewModel
    }

    ListView {
        id: blockedUsersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: blockeduserspage.header.bottom
        }
        model: viewModel.userListModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(blockeduserspage, PagesConstants.user, {
                usernameId: user.pk
            })
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.userListModel.count === 0
            onRefresh: {
                viewModel.load();
            }
        }
    }

    Component.onCompleted: {
        viewModel.load();
    }
}
