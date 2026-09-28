import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: suggestionspage

    header: PageHeaderItem {
        title: i18n.tr("Suggestions")
    }

    property alias list_loading: viewModel.isLoading

    SuggestionsViewModel {
        id: viewModel
    }

    ListView {
        id: suggestionsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: suggestionspage.header.bottom
        }
        clip: true
        model: viewModel.userListModel
        delegate: UserListItem {
            onClicked: pageLayout.pushToCurrent(suggestionspage, PagesConstants.user, {
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

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
