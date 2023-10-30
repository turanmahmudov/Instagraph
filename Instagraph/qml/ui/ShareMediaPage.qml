import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: sharemediapage

    property bool list_loading: false

    property var mediaId
    property var mediaUser

    property var threadUsers: []

    signal refreshList()

    header: PageHeaderItem {
        title: i18n.tr("Send to")
    }

    function rankedRecipientsFinished(data)
    {
        worker.sendMessage({'feed': 'ShareMediaPage', 'obj': data.ranked_recipients, 'model': rankedRecipientsModel, 'clear_model': true})
    }

    function recentRecipientsFinished(data)
    {
        worker.sendMessage({'feed': 'ShareMediaPage', 'obj': data.ranked_recipients, 'model': rankedRecipientsModel, 'clear_model': true})
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getRankedRecipients();
    }

    function getRankedRecipients()
    {
        instagram.getRankedRecipients();
    }

    function getRecentRecipients()
    {
        instagram.getRecentRecipients();
    }

    function sendMessage(text)
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+threadUsers[i]+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directShare(mediaId, recip_string, text);
    }

    ListModel {
        id: rankedRecipientsModel
    }

    ListModel {
        id: selectedUsersModel
        onCountChanged: {
            selectedUsersList.positionViewAtEnd()
        }
    }

    Column {
        anchors {
            top: sharemediapage.header.bottom
            topMargin: units.gu(1)
            bottom: addMessageItem.top
            bottomMargin: 0
            left: parent.left
            right: parent.right
        }

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

        Row {
            id: selectedUsersFlow
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
            }
            spacing: units.gu(1)

            Label {
                id: toLabel
                text: i18n.tr("To")
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }

            ListView {
                id: selectedUsersList
                width: parent.width - toLabel.width - units.gu(1)
                height: units.gu(4)
                orientation: Qt.Horizontal
                clip: true
                spacing: units.gu(0.5)
                model: selectedUsersModel
                anchors.verticalCenter: parent.verticalCenter

                delegate: Item {
                    width: username_rect.width
                    height: username_rect.height
                    clip: true
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: username_rect
                        height: username_label.height + units.gu(1.5)
                        width: username_label.width + units.gu(2.5)
                        color: LomiriColors.blue
                        radius: units.gu(0.3)
                        Label {
                            anchors.centerIn: parent
                            id: username_label
                            text: username
                            color: "#ffffff"
                            fontSize: "small"
                            font.weight: Font.DemiBold
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var userId = selectedUsersModel.get(index).userId
                                selectedUsersModel.remove(index)

                                var ind = threadUsers.indexOf(userId);
                                if (ind > -1) {
                                    threadUsers.splice(ind, 1);
                                }

                                refreshList()
                            }
                        }
                    }
                }
            }
        }

        ListItem {
            height: searchUsersField.height
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
            }
            y: units.gu(2)

            TextField {
                id: searchUsersField
                width: parent.width
                StyleHints {
                    borderColor: "transparent"
                }
                placeholderText: i18n.tr("Search")
                onAccepted: {
                    instagram.getRankedRecipients(searchUsersField.text);
                }
                onTextChanged: {
                    instagram.getRankedRecipients(searchUsersField.text);
                }
            }
        }

        ListView {
            id: recipientsList

            width: parent.width
            height: parent.height - searchUsersField.height - selectedUsersFlow.height
            clip: true
            model: rankedRecipientsModel
            delegate: ListItem {
                height: layout.height - units.gu(2)
                divider.visible: false
                onClicked: {
                    selectUserCheckBox.checked = !selectUserCheckBox.checked
                }

                SlotsLayout {
                    id: layout
                    anchors.centerIn: parent

                    mainSlot: Row {
                        id: label
                        spacing: units.gu(1)
                        width: parent.width - units.gu(5)

                        CircleImage {
                            width: units.gu(5)
                            height: width
                            source: user_obj.profile_pic_url
                        }

                        Column {
                            width: parent.width - units.gu(6)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: user_obj.username
                                wrapMode: Text.WordWrap
                                font.weight: Font.DemiBold
                                width: parent.width
                                color: styleApp.common.textColor
                            }

                            Text {
                                text: user_obj.full_name
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
                                color: styleApp.common.textColor
                            }
                        }
                    }

                    CheckBox {
                        id: selectUserCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        SlotsLayout.position: SlotsLayout.Trailing
                        SlotsLayout.overrideVerticalPositioning: true

                        checked: threadUsers.indexOf(user_obj.pk) > -1

                        onCheckedChanged: {
                            if (checked) {
                                var index = threadUsers.indexOf(user_obj.pk);
                                if (index == -1) {
                                    threadUsers.push(user_obj.pk)
                                    selectedUsersModel.append({"userId":user_obj.pk, "username":user_obj.username})
                                }
                            } else {
                                var index = threadUsers.indexOf(user_obj.pk);
                                if (index > -1) {
                                    threadUsers.splice(index, 1);

                                    for(var i = 0; i < selectedUsersModel.count; i++) {
                                           if (user_obj.pk === selectedUsersModel.get(i).userId) {
                                               selectedUsersModel.remove(i)
                                           }
                                       }
                                }
                            }

                            if (threadUsers.length > 0) {
                                addMessageItem.visible = true;
                                addMessageItem.height = units.gu(5)
                            } else {
                                addMessageItem.visible = false;
                                addMessageItem.height = 0
                            }
                        }

                        Connections {
                            target: sharemediapage
                            onRefreshList: {
                                var index = threadUsers.indexOf(user_obj.pk);
                                if (index == -1) {
                                    selectUserCheckBox.checked = false
                                } else {
                                    selectUserCheckBox.checked = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: addMessageItem
        visible: threadUsers.length > 0
        height: threadUsers.length > 0 ? units.gu(6) : 0
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        Row {
            width: parent.width
            spacing: units.gu(1)

            TextField {
                id: addMessageField
                width: parent.width - addMessageButton.width - units.gu(1)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: i18n.tr("Write a message...")
                onAccepted: {
                    sendMessage(addMessageField.text)
                }
            }

            Button {
                id: addMessageButton
                anchors.verticalCenter: parent.verticalCenter
                color: LomiriColors.green
                text: i18n.tr("Send")
                onClicked: {
                    sendMessage(addMessageField.text)
                }
            }
        }
    }

    Connections{
        target: instagram
        onRankedRecipientsDataReady: {
            var data = JSON.parse(answer);
            rankedRecipientsFinished(data);
        }
        onRecentRecipientsDataReady: {
            var data = JSON.parse(answer);
            recentRecipientsFinished(data);
        }
        onDirectShareDataReady: {
            var data = JSON.parse(answer);
            pageStack.pop();
        }
    }
}
