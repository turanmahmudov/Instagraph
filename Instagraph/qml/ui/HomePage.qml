import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: homepage

    header: PageHeader {
        title: i18n.tr("Instagraph")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [inboxAction]
        }
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property bool clear_models: true

    property bool list_loading: false

    property bool isEmpty: false

    function mediaDataFinished(data) {
        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available == true ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'homePage', 'obj': data.feed_items, 'model': homePhotosModel, 'commentsModel': homePhotosCommentsModel, 'suggestionsModel': homeSuggestionsModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            Storage.set("media_or_ad", JSON.stringify(messageObject))
        }
    }

    function getMedia(next_id)
    {
        clear_models = false
        if (!next_id) {
            homePhotosModel.clear()
            next_max_id = 0
            clear_models = true
        }
        instagram.getTimeLine(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: homepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: homePhotosCommentsModel
    }

    ListModel {
        id: homePhotosModel
    }

    ListModel {
        id: homeSuggestionsModel
    }

    Column {
        id: homeSuggestionsList
        visible: homeSuggestionsModel.count > 0
        z: 10
        anchors {
            left: parent.left
            right: parent.right
            top: homepage.header.bottom
        }

        ListItem {
            height: suggestionsHeaderRow.height + units.gu(4)
            color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

            Row {
                id: suggestionsHeaderRow
                width: parent.width
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: i18n.tr("Suggestions for You")
                    width: parent.width - suggestionsCloseRectangle.width
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    id: suggestionsCloseRectangle
                    height: parent.height
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                    color: "transparent"

                    Row {
                        width: parent.width

                        Icon {
                            height: units.gu(2)
                            width: height
                            name: "close"
                            color: UbuntuColors.darkGrey
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            homeSuggestionsList.visible = false
                            homePhotosList.anchors.top = homepage.header.bottom
                        }
                    }
                }
            }
        }

        Repeater {
            model: homeSuggestionsModel

            ListItem {
                id: searchUsersDelegate
                divider.visible: true
                height: entry_column.height + units.gu(1)
                color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                Column {
                    id: entry_column
                    spacing: units.gu(1)
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        right: parent.right
                        rightMargin: units.gu(1)
                    }

                    Item {
                        width: parent.width
                        height: units.gu(0.1)
                    }

                    Row {
                        spacing: units.gu(1)
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        Item {
                            width: units.gu(5)
                            height: width

                            UbuntuShape {
                                width: parent.width
                                height: width
                                radius: "large"

                                source: Image {
                                    id: feed_user_profile_image
                                    width: parent.width
                                    height: width
                                    source: status == Image.Error ? "../images/not_found_user.jpg" : user.profile_pic_url
                                    fillMode: Image.PreserveAspectCrop
                                    anchors.centerIn: parent
                                    sourceSize: Qt.size(width,height)
                                    smooth: true
                                    clip: true
                                }
                            }

                            Item {
                                width: activity.width
                                height: width
                                anchors.centerIn: parent
                                opacity: feed_user_profile_image.status == Image.Loading

                                Behavior on opacity {
                                    UbuntuNumberAnimation {
                                        duration: UbuntuAnimation.SlowDuration
                                    }
                                }

                                ActivityIndicator {
                                    id: activity
                                    running: true
                                }
                            }
                        }

                        Column {
                            width: parent.width - units.gu(12)
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: user.username
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                font.weight: Font.DemiBold
                                width: parent.width
                            }

                            Text {
                                text: user.full_name
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                width: parent.width
                            }
                        }

                        FollowComponent {
                            width: units.gu(5)
                            height: units.gu(3)
                            friendship_var: {"following": false, "outgoing_request": false}
                            userId: user.pk
                        }
                    }
                }

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameString: user.username});
                }
            }
        }

        ListItem {
            height: suggestionsFooterRow.height + units.gu(4)
            color: Qt.lighter(UbuntuColors.lightGrey, 1.2)
            divider.visible: false

            Row {
                id: suggestionsFooterRow
                width: parent.width
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: parent.right
                    rightMargin: units.gu(1)
                }
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: i18n.tr("See All Suggestions")
                    width: parent.width
                    color: "#275A84"
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                //pageStack.push(Qt.resolvedUrl("SuggestionsPage.qml"));
            }
        }
    }

    ListView {
        id: homePhotosList
        visible: !isEmpty
        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
            bottom: bottomMenu.top
            top: homeSuggestionsModel.count == 0 ? homepage.header.bottom : homeSuggestionsList.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getMedia(next_max_id);
            }
        }

        cacheBuffer: parent.height*2
        model: homePhotosModel
        delegate: ListFeedDelegate {
            id: homePhotosDelegate
            thismodel: homePhotosModel
            thiscommentsmodel: homePhotosCommentsModel
        }
        PullToRefresh {
            id: pullToRefresh
            refreshing: list_loading && homePhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getMedia()
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: homeSuggestionsModel.count == 0 ? homepage.header.bottom : homeSuggestionsList.bottom
            horizontalCenter: parent.horizontalCenter
        }

        title: i18n.tr("Welcome to Instagraph!")
        description: i18n.tr("Follow accounts to see photos and videos here in your feed.")
    }

    FloatingActionButton {
        z: 1
        visible: homePhotosList.contentY > units.gu(150)
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: units.gu(1)
            bottomMargin: units.gu(7)
        }
        imageName: "go-up"
        backgroundColor: "#2B2B2B"
        onClicked: {
            homePhotosList.positionViewAtBeginning();
        }
    }

    Connections{
        target: instagram
        onTimeLineDataReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                mediaDataFinished(data);
            } else {
                // error
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
