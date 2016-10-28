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

    property var threadUsers: []

    header: PageHeader {
        title: i18n.tr("Send To")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
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
        trailingActionBar {
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
        }
    }

    PageHeader {
        id: searchHeader
        visible: sharemediapage.header === searchHeader
        title: i18n.tr("Search")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
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
            StyleHints {
                backgroundColor: "#0D4168"
                foregroundColor: "#ffffff"
                borderColor: "#0D4168"
                textColor: "#ffffff"
                placeholderTextColor: "#ffffff"
                selectedTextColor: "#ffffff"
            }
            primaryItem: Icon {
                anchors.leftMargin: units.gu(0.2)
                height: parent.height*0.5
                width: height
                name: "find"
            }
            color: "#ffffff"
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

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        getRankedRecipients();
        //getRecentRecipients();
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
            if (i != 0) {
                recip_array.push('"'+i+'"');
            }
        }
        recip_string = recip_array.join(',');

        instagram.directShare(mediaId, recip_string, text);
    }

    ListModel {
        id: rankedRecipientsModel
        dynamicRoles: true
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

        Flickable {
            width: parent.width
            height: usersRow.height

            contentWidth: usersRow.width
            contentHeight: usersRow.height

            Row {
                id: usersRow
                spacing: units.gu(4)

                Repeater {
                    model: rankedRecipientsModel

                    Column {
                        width: units.gu(9)
                        spacing: units.gu(1)

                        UbuntuShape {
                            width: units.gu(7)
                            height: width
                            radius: "large"
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: Image {
                                anchors {
                                    centerIn: parent
                                }
                                width: parent.width
                                height: width
                                source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(width,height)
                                asynchronous: true
                                cache: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    threadUsers.push(user.pk)
                                }
                            }
                        }

                        Column {
                            width: parent.width

                            Label {
                                text: user.username
                                color: "#000000"
                                fontSize: "small"
                                font.weight: Font.DemiBold
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Label {
                                text: user.full_name
                                fontSize: "small"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: addMessageItem
            height: units.gu(5)
            width: parent.width
            visible: rankedRecipientsModel.count > 0

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
            console.log(answer)
            var data = JSON.parse(answer);
            recentRecipientsFinished(data);
        }
        onDirectShareReady: {
            console.log(answer)
        }
    }
}
