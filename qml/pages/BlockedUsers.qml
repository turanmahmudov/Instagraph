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

    BaseUserListViewModel {
        id: viewModel
        hasPagination: false
        dataKey: "blocked_list"
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
                loadBlockedUsers();
            }
        }
    }

    function loadBlockedUsers() {
        viewModel.loadData('', function () {
            instagram.getBlockedUserList();
        });
    }

    Connections {
        target: instagram
        function onBlockedUserListDataReady(answer) {
            viewModel.handleResponse(answer);
        }
    }

    Component.onCompleted: {
        loadBlockedUsers();
    }
}
