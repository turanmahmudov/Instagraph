import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: userpage

    header: PageHeader {
        title: i18n.tr("User")
        leadingActionBar.actions: [
            Action {
                id: addPeopleAction
                text: i18n.tr("Suggestions")
                iconName: "contact-new"
                onTriggered: {
                    pageStack.push(Qt.resolvedUrl("SuggestionsPage.qml"));
                }
            }
        ]
        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    id: settingsAction
                    text: i18n.tr("Settings")
                    iconName: "settings"
                    onTriggered: {
                        pageStack.push(Qt.resolvedUrl("OptionsPage.qml"));
                    }
                }
            ]
        }
    }

    property var next_max_id
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property bool clear_models: true

    property int current_user_section: 0

    property bool list_loading: false

    property bool isEmpty: false

    function usernameDataFinished(data) {
        userPage.header.title = data.user.username;
        uzimage.source = data.user.profile_pic_url;
        uzname.text = data.user.full_name;
        uzbio.text = data.user.biography;
        uzexternal.text = '<a href="'+data.user.external_url+'" style="text-decoration:none;color:rgb(0,53,105);">'+data.user.external_url+'</a>';
        uzmedia_count.text = data.user.media_count;
        uzfollower_count.text = data.user.follower_count;
        uzfollowing_count.text = data.user.following_count;
    }

    function userTimeLineDataFinished(data) {
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

            worker.sendMessage({'feed': 'userPage', 'obj': data.items, 'model': userPhotosModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    function userTagDataFinished(data) {
        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id;
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'userPage', 'obj': data.items, 'model': userTagPhotosModel, 'clear_model': clear_models})

            next_coming = false;
        }

        list_loading = false
    }

    WorkerScript {
        id: worker
        source: "../js/Worker.js"
        onMessage: {
            console.log(msg)
        }
    }

    function getUsernameInfo()
    {
        instagram.getUsernameInfo(my_usernameId);
    }

    function getUsernameFeed(next_id)
    {
        clear_models = false
        if (!next_id) {
            userPhotosModel.clear();
            next_max_id = 0
            clear_models = true
        }
        instagram.getUsernameFeed(my_usernameId, next_id);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: userpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: userPhotosModel
    }

    ListModel {
        id: userTagPhotosModel
    }

    Flickable {
        id: flickpage
        anchors {
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: userpage.header.bottom
        }
        clip: true
        width: parent.width
        height: parent.height
        contentWidth: parent.width
        contentHeight: entry_column.height
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getUsernameFeed(next_max_id);
            }
        }

        Column {
            id: entry_column
            width: parent.width
            y: units.gu(1)

            Column {
                x: units.gu(1)
                spacing: units.gu(2)
                width: parent.width - units.gu(2)

                Row {
                    spacing: units.gu(1)
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    CircleImage {
                        id: uzimage
                        width: units.gu(10)
                        height: width
                        source: typeof profile_pic_url !== 'undefined' ? profile_pic_url : "../images/not_found_user.jpg"
                    }

                    Column {
                        spacing: units.gu(1)
                        width: parent.width - units.gu(11)
                        anchors.verticalCenter: parent.verticalCenter

                        Row {
                            spacing: units.gu(1)
                            width: parent.width
                            anchors.horizontalCenter: parent.horizontalCenter

                            Column {
                                width: (parent.width-units.gu(2))/3

                                Label {
                                    id: uzmedia_count
                                    fontSize: "medium"
                                    font.weight: Font.Bold
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                                Label {
                                    text: i18n.tr("posts")
                                    fontSize: "medium"
                                    font.weight: Font.Light
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }

                            Column {
                                width: (parent.width-units.gu(2))/3

                                Label {
                                    id: uzfollower_count
                                    fontSize: "medium"
                                    font.weight: Font.Bold
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            pageStack.push(Qt.resolvedUrl("UserFollowers.qml"), {userId: my_usernameId});
                                        }
                                    }
                                }
                                Label {
                                    text: i18n.tr("followers")
                                    fontSize: "medium"
                                    font.weight: Font.Light
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            pageStack.push(Qt.resolvedUrl("UserFollowers.qml"), {userId: my_usernameId});
                                        }
                                    }
                                }
                            }

                            Column {
                                width: (parent.width-units.gu(2))/3

                                Label {
                                    id: uzfollowing_count
                                    fontSize: "medium"
                                    font.weight: Font.Bold
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            pageStack.push(Qt.resolvedUrl("UserFollowings.qml"), {userId: my_usernameId});
                                        }
                                    }
                                }
                                Label {
                                    text: i18n.tr("following")
                                    fontSize: "medium"
                                    font.weight: Font.Light
                                    wrapMode: Text.WordWrap
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    MouseArea {
                                        width: parent.width
                                        height: parent.height
                                        onClicked: {
                                            pageStack.push(Qt.resolvedUrl("UserFollowings.qml"), {userId: my_usernameId});
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: UbuntuColors.green
                            text: i18n.tr("Edit your profile")
                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("EditProfilePage.qml"));
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: units.gu(0.5)

                    Label {
                        id: uzname
                        fontSize: "medium"
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        id: uzbio
                        width: parent.width
                        wrapMode: Text.WordWrap
                        onLinkActivated: {
                            Scripts.linkClick(link)
                        }
                    }

                    Text {
                        id: uzexternal
                        wrapMode: Text.WordWrap
                        width: parent.width
                        textFormat: Text.RichText
                        onLinkActivated: {
                            Scripts.linkClick(link)
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: units.gu(2)
            }

            Column {
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(0.5)
                y: units.gu(2)

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                }

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    spacing: (parent.width-units.gu(15))/3

                    Item {
                        width: units.gu(5)
                        height: width

                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(3)
                            height: width
                            name: "view-grid-symbolic"
                            color: current_user_section == 0 ? "#003569" : UbuntuColors.darkGrey
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                current_user_section = 0
                                viewLoader.sourceComponent = gridviewComponent
                            }
                        }
                    }

                    Item {
                        width: units.gu(5)
                        height: width

                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(3)
                            height: width
                            name: "view-list-symbolic"
                            color: current_user_section == 1 ? "#003569" : UbuntuColors.darkGrey
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                current_user_section = 1
                                viewLoader.sourceComponent = listviewComponent
                            }
                        }
                    }

                    Item {
                        width: units.gu(5)
                        height: width

                        Icon {
                            anchors.centerIn: parent
                            width: units.gu(3)
                            height: width
                            name: "contact"
                            color: current_user_section == 3 ? "#003569" : UbuntuColors.darkGrey
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next_max_id = 0
                                instagram.getUserTags(my_usernameId)
                                current_user_section = 3
                                viewLoader.sourceComponent = tagviewComponent
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                }
            }

            Column {
                visible: !isEmpty
                width: !isEmpty ? parent.width : 0
                anchors.horizontalCenter: parent.horizontalCenter

                Loader {
                    id: viewLoader
                    width: parent.width
                    sourceComponent: gridviewComponent
                }
            }

            EmptyBox {
                visible: isEmpty
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                icon: current_user_section == 3 ? true : false
                iconName: current_user_section == 3 ? "stock_image" : ""

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? i18n.tr("Photos you're tagged in will appear here.") : i18n.tr("Start capturing and sharing your moments")
            }
        }
        PullToRefresh {
            parent: flickpage
            refreshing: list_loading && userPhotosModel.count == 0
            onRefresh: {
                list_loading = true
                getUsernameInfo()
                getUsernameFeed()
            }
        }
    }

    Component {
        id: listviewComponent

        ListView {
            width: viewLoader.width
            height: contentHeight
            interactive: false
            model: userPhotosModel
            delegate: ListFeedDelegate {
                id: userPhotosDelegate
                thismodel: userPhotosModel
            }
        }
    }

    Component {
        id: gridviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: userPhotosModel

                GridFeedDelegate {
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width
                }
            }
        }
    }

    Component {
        id: tagviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: userTagPhotosModel

                GridFeedDelegate {
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width
                }
            }
        }
    }

    Connections{
        target: instagram
        onUserTimeLineDataReady: {
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                userTimeLineDataFinished(data);
            } else {
                // error
            }
        }
        onUsernameDataReady: {
            var data = JSON.parse(answer);
            usernameDataFinished(data);
        }
        onUserTagsDataReady: {
            var data = JSON.parse(answer);
            userTagDataFinished(data);
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
