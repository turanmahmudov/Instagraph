import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: discoverpeoplepage

    header: PageHeader {
        title: i18n.tr("Discover People")
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
    }

    property string next_max_id: ""
    property bool more_available: true
    property bool next_coming: true

    property bool list_loading: false
    property bool clear_models: true

    function discoverPeopleDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.more_available == true ? data.next_max_id : "";
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'discoverPeoplePage', 'obj': data.items, 'model': discoverPeopleModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/SimpleWorker.js"
        onMessage: {
            console.log(msg)
        }
    }

    Component.onCompleted: {
        discoverPeople();
    }

    function discoverPeople(next_id)
    {
        clear_models = false;
        if (!next_id) {
            discoverPeopleModel.clear()
            next_max_id = ""
            clear_models = true
        }
        instagram.explore(next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: discoverpeoplepage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: discoverPeopleModel
    }

    ListView {
        id: recentActivityList
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: discoverpeoplepage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                discoverPeople(next_max_id)
            }
        }

        clip: true
        cacheBuffer: discoverpeoplepage.height*2
        model: discoverPeopleModel
        delegate: ListItem {
            id: searchUsersDelegate
            divider.visible: false
            height: entry_column.height + units.gu(2)

            Column {
                id: entry_column
                spacing: units.gu(1)
                y: units.gu(1)
                width: parent.width
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
                                source: status == Image.Error ? "../images/not_found_user.jpg" : media.user.profile_pic_url
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
                            text: media.user.username
                            font.weight: Font.DemiBold
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }

                        Text {
                            text: media.user.full_name
                            wrapMode: Text.WordWrap
                            width: parent.width
                        }
                    }

                    FollowComponent {
                        width: units.gu(5)
                        height: units.gu(3)
                        friendship_var: media.user.friendship_status
                        userId: media.user.pk
                    }
                }
            }

            onClicked: {
                pageStack.push(Qt.resolvedUrl("OtherUserPage.qml"), {usernameString: media.user.username});
            }
        }
        PullToRefresh {
            refreshing: list_loading && discoverPeopleModel.count == 0
            onRefresh: {
                list_loading = true
                discoverPeople()
            }
        }
    }

    Connections{
        target: instagram
        onExploreDataReady: {
            //console.log(answer)
            var data = JSON.parse(answer);
            discoverPeopleDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
