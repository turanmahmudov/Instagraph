import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: newdirectmessagepage

    property bool list_loading: false

    property var threadUsers: []

    header: PageHeader {
        title: i18n.tr("New Message")
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

        instagram.directMessage(recip_string, text, "");
    }

    function sendLike()
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+threadUsers[i]+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directLike(recip_string, "");
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: newdirectmessagepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: rankedRecipientsModel
    }

    Column {
        anchors {
            top: newdirectmessagepage.header.bottom
            topMargin: units.gu(1)
            bottom: addMessageItem.top
            bottomMargin: units.gu(1)
            left: parent.left
            right: parent.right
        }

        TextField {
            id: searchUsersField
            anchors {
                left: parent.left
                leftMargin: units.gu(1)
                right: parent.right
                rightMargin: units.gu(1)
            }
            //width: parent.width
            placeholderText: i18n.tr("Search")
            onAccepted: {
                instagram.getRankedRecipients(searchUsersField.text);
            }
            onTextChanged: {
                instagram.getRankedRecipients(searchUsersField.text);
            }
        }

        ListView {
            id: recipientsList

            width: parent.width
            height: parent.height - searchUsersField.height
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
                            }

                            Text {
                                text: user_obj.full_name
                                wrapMode: Text.WordWrap
                                width: parent.width
                                textFormat: Text.RichText
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
                                }
                            } else {
                                var index = threadUsers.indexOf(user_obj.pk);
                                if (index > -1) {
                                    threadUsers.splice(index, 1);
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
                    }
                }
            }
        }
    }

    Item {
        id: addMessageItem
        visible: threadUsers.length > 0
        height: threadUsers.length > 0 ? units.gu(5) : 0
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
                width: parent.width - addMessageButton.width - sendLikeButton.width - units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                placeholderText: i18n.tr("Write a message...")
                onAccepted: {
                    sendMessage(addMessageField.text)
                }
            }

            Icon {
                id: sendLikeButton
                anchors.verticalCenter: parent.verticalCenter
                color: UbuntuColors.red
                height: units.gu(3)
                width: height
                name: "unlike"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        sendLike()
                    }
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
        onDirectMessageReady: {
            var data = JSON.parse(answer)
            if (data.status == "ok") {
                pageStack.push(Qt.resolvedUrl("DirectThreadPage.qml"), {threadId: data.threads[0].thread_id});
            }
        }
        onDirectLikeReady: {
            var data = JSON.parse(answer)
            if (data.status == "ok") {
                pageStack.push(Qt.resolvedUrl("DirectThreadPage.qml"), {threadId: data.threads[0].thread_id});
            }
        }
    }
}
