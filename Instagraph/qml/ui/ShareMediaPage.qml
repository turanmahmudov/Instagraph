import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: sharemediapage

    property bool list_loading: false

    property var mediaId
    property var mediaUser

    property var threadUsers: []

    property bool clear_models: true

    header: PageHeader {
        title: i18n.tr("Send To")
        leadingActionBar.actions: [
            Action {
                id: closePageAction
                text: i18n.tr("Close")
                iconName: "close"
                onTriggered: {
                    pageStack.pop();
                }
            }
        ]
        /*trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: searchUsersAction
                    text: i18n.tr("Search")
                    iconName: "find"
                    onTriggered: {
                        sharemediapage.header = searchHeader
                    }
                }
            ]
        }*/
    }

    PageHeader {
        id: searchHeader
        visible: sharemediapage.header === searchHeader
        title: i18n.tr("Search")
        leadingActionBar.actions: [
            Action {
                id: closePageAction2
                text: i18n.tr("Close")
                iconName: "close"
                onTriggered: {
                    pageStack.pop();
                }
            }
        ]
        contents: TextField {
            id: searchInput
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            primaryItem: Icon {
                anchors.leftMargin: units.gu(0.2)
                height: parent.height*0.5
                width: height
                name: "find"
            }
            hasClearButton: true
            placeholderText: i18n.tr("Search")
            onAccepted: {

            }
        }
    }

    function rankedRecipientsFinished(data)
    {
        worker.sendMessage({'feed': 'ShareMediaPage', 'obj': data.ranked_recipients, 'model': rankedRecipientsModel, 'clear_model': true})
    }

    function recentRecipientsFinished(data)
    {
        worker.sendMessage({'feed': 'ShareMediaPage', 'obj': data.ranked_recipients, 'model': rankedRecipientsModel, 'clear_model': true})
    }

    function userFollowingsDataFinished(data) {
        userFollowingsModel.clear()

        worker.sendMessage({'feed': 'UserFollowingsPage', 'obj': data.users, 'model': userFollowingsModel, 'clear_model': clear_models})
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        //getRankedRecipients();
        //getRecentRecipients();
        getUserFollowings();
    }

    function getRankedRecipients()
    {
        instagram.getRankedRecipients();
    }

    function getRecentRecipients()
    {
        instagram.getRecentRecipients();
    }

    function getUserFollowings(next_id)
    {
        clear_models = false
        if (!next_id) {
            userFollowingsModel.clear()
            clear_models = true
        }
        instagram.getUserFollowings(my_usernameId);
    }

    function sendMessage(text)
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            if (threadUsers[i] != 0) {
                recip_array.push('"'+threadUsers[i]+'"');
            }
        }
        recip_string = recip_array.join(',');

        instagram.directShare(mediaId, recip_string, text);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: sharemediapage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: rankedRecipientsModel
    }

    ListModel {
        id: userFollowingsModel
    }

    Column {
        id: entryColumn
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            top: sharemediapage.header.bottom
            topMargin: units.gu(2)
        }
        spacing: units.gu(2)

        Column {
            id: privateUserWarning
            width: parent.width
            visible: mediaUser.is_private

            Label {
                text: i18n.tr("%1 has a private account.").arg(mediaUser.username)
                fontSize: "small"
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: i18n.tr("Only their followers will be able to see this photo.")
                fontSize: "small"
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        ListView {
            width: parent.width
            height: units.gu(15)

            clip: true

            snapMode: ListView.SnapToItem
            orientation: Qt.Horizontal
            highlightMoveDuration: UbuntuAnimation.FastDuration
            highlightRangeMode: ListView.ApplyRange
            highlightFollowsCurrentItem: true

            model: userFollowingsModel

            delegate: ListItem {
                width: units.gu(10)
                height: storyColumn.height
                divider.visible: false

                property bool selected: false

                Column {
                    id: storyColumn
                    width: parent.width - units.gu(2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1)

                    CircleImage {
                        width: parent.width
                        height: width
                        source: typeof profile_pic_url != 'undefined' ? profile_pic_url : "../images/not_found_user.jpg"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (!selected) {
                                    selected = true
                                    threadUsers.push(pk)
                                } else {
                                    selected = false

                                    var index = threadUsers.indexOf(pk);
                                    if (index > -1) {
                                        threadUsers.splice(index, 1);
                                    }
                                }

                                if (threadUsers.length > 0) {
                                    addMessageItem.visible = true;
                                } else {
                                    addMessageItem.visible = false;
                                }
                            }
                        }
                    }

                    Column {
                        width: parent.width

                        Label {
                            text: username
                            color: "#000000"
                            fontSize: "small"
                            font.weight: Font.DemiBold
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min((parent.width+2), contentWidth)
                            clip: true
                        }

                        Label {
                            text: full_name
                            fontSize: "small"
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min((parent.width+2), contentWidth)
                            clip: true
                        }

                        Item {
                            width: parent.width
                            height: units.gu(1)
                        }

                        Rectangle {
                            visible: selected
                            width: parent.width
                            height: units.gu(0.3)
                            color: "#275A84"
                        }
                    }
                }
            }
        }

        Item {
            id: addMessageItem
            height: units.gu(5)
            width: parent.width
            visible: false

            Row {
                width: parent.width
                spacing: units.gu(1)

                TextField {
                    id: addMessageField
                    width: parent.width - addMessageButton.width - units.gu(1)
                    anchors.verticalCenter: parent.verticalCenter
                    placeholderText: i18n.tr("Add a message...")
                    onAccepted: {
                        sendMessage(addMessageField.text)
                    }
                }

                Button {
                    id: addMessageButton
                    anchors.verticalCenter: parent.verticalCenter
                    color: UbuntuColors.green
                    text: i18n.tr("Send")
                    onClicked: {
                        sendMessage(addMessageField.text)
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onRankedRecipientsDataReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            rankedRecipientsFinished(data);
        }
        onRecentRecipientsDataReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            recentRecipientsFinished(data);
        }
        onUserFollowingsDataReady: {
            var data = JSON.parse(answer);
            userFollowingsDataFinished(data);
        }
        onDirectShareReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            pageStack.pop();
        }
    }
}
