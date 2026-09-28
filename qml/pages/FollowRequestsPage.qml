import QtQuick 2.12
import Lomiri.Components 1.3

import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../viewmodels"

PageItem {
    id: followrequestspage

    header: PageHeaderItem {
        title: i18n.tr("Follow Requests")
    }

    property alias list_loading: viewModel.isLoading

    FollowRequestsViewModel {
        id: viewModel
    }

    ListView {
        id: followRequestsList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: followrequestspage.header.bottom
        }

        clip: true
        cacheBuffer: followrequestspage.height * 2
        model: viewModel.userListModel
        delegate: ListItem {
            id: followRequestDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageLayout.pushToCurrent(followrequestspage, PagesConstants.user, {
                    usernameId: user.pk
                });
            }

            property var approvedFriendship: null

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: UserRowSlot {
                    width: parent.width - (approvedFriendship ? followButton.width : buttons.width)
                }

                Row {
                    id: buttons
                    visible: !approvedFriendship
                    width: visible ? childrenRect.width : 0
                    spacing: units.gu(1)

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true

                    Button {
                        color: LomiriColors.blue
                        text: i18n.tr("Confirm")
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: viewModel.approve(user.pk)
                    }

                    Button {
                        color: LomiriColors.lightGrey
                        text: i18n.tr("Delete")
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: viewModel.reject(user.pk)
                    }
                }

                FollowComponent2 {
                    id: followButton
                    visible: !!approvedFriendship
                    userId: user.pk
                    friendship: approvedFriendship
                    showLabel: true

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }

            Connections {
                target: viewModel
                function onRequestApproved(userId, friendship) {
                    if (userId == user.pk) {
                        approvedFriendship = friendship;
                    }
                }
            }
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
