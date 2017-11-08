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

        for (var i = 0; i < data.groups[0].items.length; i++) {

            suggestionsModel.append(data.groups[0].items[i]);
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
            divider.visible: false
            height: entry_column.height + units.gu(2)

            Column {
                id: entry_column
                spacing: units.gu(1)
                width: parent.width
                y: units.gu(1)
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }

                Row {
                    spacing: units.gu(1)
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    CircleImage {
                        id: feed_user_profile_image
                        width: units.gu(5)
                        height: width
                        source: status == Image.Error ? "../images/not_found_user.jpg" : user.profile_pic_url
                    }

                    Column {
                        width: parent.width - units.gu(12)
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: user.username
                            font.weight: Font.DemiBold
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: user.full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                            textFormat: Text.RichText
                        }
                    }

                    FollowComponent {
                        width: units.gu(5)
                        height: units.gu(3)
                        friendship_var: user.friendship_status
                        userId: user.pk
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameString: user.username});
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
            //console.log(answer)
            var data = JSON.parse(answer);
            suggestionsDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
