import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: medialikerspage

    header: PageHeaderItem {
        title: i18n.tr("Likes")
    }

    property var mediaId

    property alias list_loading: viewModel.isLoading

    BaseUserListViewModel {
        id: viewModel
        hasPagination: false
    }

    ListView {
        id: mediaLikersList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: medialikerspage.header.bottom
        }
        model: viewModel.userListModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(medialikerspage, PagesConstants.user, {
                usernameId: user.pk
            })
        }
        PullToRefresh {
            refreshing: viewModel.isLoading && viewModel.userListModel.count === 0
            onRefresh: {
                loadLikers();
            }
        }
    }

    function loadLikers() {
        viewModel.loadData('', function () {
            instagram.getMediaLikers(mediaId);
        });
    }

    Connections {
        target: instagram
        onMediaLikersDataReady: {
            viewModel.handleResponse(answer);
        }
    }

    Component.onCompleted: {
        loadLikers();
    }
}
