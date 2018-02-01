import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: suggestionspage

    header: PageHeader {
        title: i18n.tr("Suggestions")
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    property bool list_loading: false

    function suggestionsDataFinished(data) {
        more_available = data.more_available
        next_coming = true

        for (var i = 0; i < data.suggested_users.suggestions.length; i++) {

            suggestionsModel.append(data.suggested_users.suggestions[i]);
        }

        next_coming = false;

        list_loading = false
    }

    Component.onCompleted: {
        suggestions();
    }

    function suggestions()
    {
        suggestionsModel.clear()
        list_loading = true
        instagram.suggestions();
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: suggestionspage.header.bottom
        visible: instagram.busy
    }

    ListModel {
        id: suggestionsModel
    }

    ListView {
        id: recentActivityList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: suggestionspage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                suggestions()
            }
        }

        clip: true
        cacheBuffer: suggestionspage.height*2
        model: suggestionsModel
        delegate: ListItem {
            id: searchUsersDelegate
            height: layout.height
            divider.visible: false
            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameId: user.pk});
            }

            SlotsLayout {
                id: layout
                anchors.centerIn: parent

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(1)
                padding.bottom: units.gu(1)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: parent.width - followButton.width

                    CircleImage {
                        width: units.gu(5)
                        height: width
                        source: user.profile_pic_url
                    }

                    Column {
                        width: parent.width - units.gu(6)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: user.username
                            wrapMode: Text.WordWrap
                            font.weight: Font.DemiBold
                            width: parent.width
                        }

                        Text {
                            text: user.full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }
                }

                FollowComponent {
                    id: followButton
                    height: units.gu(3.5)
                    friendship_var: {"following": false, "outgoing_request": false}
                    userId: user.pk
                    just_icon: false

                    anchors.verticalCenter: parent.verticalCenter
                    SlotsLayout.position: SlotsLayout.Trailing
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
        PullToRefresh {
            refreshing: list_loading && suggestionsModel.count == 0
            onRefresh: suggestions()
        }
    }

    Connections{
        target: instagram
        onSuggestionsDataReady: {
            var data = JSON.parse(answer);
            suggestionsDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
