import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: otheruserpage

    header: PageHeader {
        title: usernameString
        StyleHints {
            backgroundColor: "#275A84"
            foregroundColor: "#ffffff"
        }
        trailingActionBar {
            numberOfSlots: 1
            actions: [
                Action {
                    visible: usernameId != my_usernameId
                    id: userMenuAction
                    text: i18n.tr("Options")
                    iconName: "contextual-menu"
                    onTriggered: {
                        if (usernameId != my_usernameId) {
                            PopupUtils.open(userMenuComponent)
                        } else {
                            pageStack.push(Qt.resolvedUrl("OptionsPage.qml"));
                        }
                    }
                },
                Action {
                    visible: usernameId == my_usernameId
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

    property var usernameString
    property var usernameId

    property var latest_follow_request

    property bool selfProfile
    property bool isPrivate: false

    property var next_max_id
    property bool more_available: true
    property bool next_coming: true
    property var last_like_id
    property bool clear_models: true

    property int current_user_section: 0

    property bool list_loading: false

    property bool isEmpty: false

    function usernameDataFinished(data) {
        otheruserpage.header.title = data.user.username;
        uzimage.source = data.user.profile_pic_url;
        uzname.text = data.user.full_name;
        uzbio.text = data.user.biography;
        uzexternal.text = '<a href="'+data.user.external_url+'" style="text-decoration:none;color:rgb(0,53,105);">'+data.user.external_url+'</a>';
        uzmedia_count.text = data.user.media_count;
        uzfollower_count.text = data.user.follower_count;
        uzfollowing_count.text = data.user.following_count;
    }

    function userTimeLineDataFinished(data) {
        //console.log(JSON.stringify(data))
        if (data.num_results == 0) {
            isEmpty = true;
        } else {
            isEmpty = false;
        }

        if (next_max_id == data.next_max_id) {
            return false;
        } else {
            next_max_id = data.next_max_id;
            more_available = data.more_available;
            next_coming = true;

            worker.sendMessage({'feed': 'userPage', 'obj': data.items, 'model': userPhotosModel, 'commentsModel': userPhotosCommentsModel, 'clear_model': clear_models})

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

    function userGeoDataFinished(data) {
        worker.sendMessage({'feed': 'userPage', 'obj': data.geo_media, 'model': userGeoPhotosModel, 'clear_model': clear_models})

        list_loading = false
    }

    function followDataFinished(data) {
        if (usernameId == latest_follow_request) {
            if (data.friendship_status) {
                followingButton.visible = data.friendship_status.following
                unfollowingButton.visible = !data.friendship_status.following && !data.friendship_status.outgoing_request && !data.friendship_status.blocking
                requestedButton.visible = data.friendship_status.outgoing_request
                unBlockButton.visible = data.friendship_status.blocking

                latest_follow_request = 0
            }
        }
    }

    Component.onCompleted: {
        if (usernameId) {
            if (usernameId == my_usernameId) {
                selfProfile = true

                getUsernameFeed();
            } else {
                selfProfile = false

                instagram.userFriendship(usernameId);
            }

            getUsernameInfo()
        } else {
            instagram.searchUsername(usernameString)
        }
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
        instagram.getUsernameInfo(usernameId);
    }

    function getUsernameFeed(next_id)
    {
        clear_models = false
        if (!next_id) {
            userPhotosModel.clear();
            userPhotosCommentsModel.clear();
            next_max_id = 0
            clear_models = true
        }
        instagram.getUsernameFeed(usernameId, next_id);
    }

    Component {
        id: userMenuComponent
        ActionSelectionPopover {
            id: userMenuPopup
            target: otheruserpage.header
            delegate: ListItem {
                height: entry_column.height + units.gu(4)

                Column {
                    id: entry_column
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1)
                    width: parent.width - units.gu(4)
                    y: units.gu(2)

                    Label {
                        text: action.text
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                    }
                }
            }
            actions: ActionList {
                  Action {
                      text: i18n.tr("Block")
                      onTriggered: {
                            instagram.block(usernameId)
                      }
                  }
            }

            Connections {
                target: instagram
                onBlockDataReady: {
                    var data = JSON.parse(answer);

                    if (data.friendship_status.blocking) {
                        followingButton.visible = false
                        unfollowingButton.visible = false
                        requestedButton.visible = false
                        unBlockButton.visible = true

                        PopupUtils.close(userMenuPopup)
                    }
                }
            }
        }
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: otheruserpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: userPhotosCommentsModel
    }

    ListModel {
        id: userPhotosModel
    }

    ListModel {
        id: userTagPhotosModel
    }

    ListModel {
        id: userGeoPhotosModel
    }

    Flickable {
        id: flickpage
        anchors {
            bottom: parent.bottom
            bottomMargin: bottomMenu.height
            top: otheruserpage.header.bottom
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

                    Item {
                        width: units.gu(10)
                        height: width

                        UbuntuShape {
                            width: parent.width
                            height: width
                            radius: "large"

                            source: Image {
                                id: uzimage
                                width: parent.width
                                height: width
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
                            opacity: uzimage.status == Image.Loading

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
                                            pageStack.push(Qt.resolvedUrl("UserFollowers.qml"), {userId: usernameId});
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
                                            pageStack.push(Qt.resolvedUrl("UserFollowers.qml"), {userId: usernameId});
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
                                            pageStack.push(Qt.resolvedUrl("UserFollowings.qml"), {userId: usernameId});
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
                                            pageStack.push(Qt.resolvedUrl("UserFollowings.qml"), {userId: usernameId});
                                        }
                                    }
                                }
                            }
                        }

                        Button {
                            id: followingButton
                            visible: false
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: UbuntuColors.green
                            text: i18n.tr("Following")
                            onTriggered: {
                                latest_follow_request = usernameId
                                instagram.unFollow(usernameId)
                            }
                        }

                        Button {
                            id: unfollowingButton
                            visible: false
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Follow")
                            onTriggered: {
                                latest_follow_request = usernameId
                                instagram.follow(usernameId)
                            }
                        }

                        Button {
                            id: requestedButton
                            visible: false
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Requested")
                            onTriggered: {
                                latest_follow_request = usernameId
                                instagram.unFollow(usernameId)
                            }
                        }

                        Button {
                            id: unBlockButton
                            visible: false
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: i18n.tr("Unblock")
                            onTriggered: {
                                latest_follow_request = usernameId
                                instagram.unBlock(usernameId)
                            }
                        }

                        Button {
                            visible: selfProfile
                            width: parent.width - units.gu(2)
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: UbuntuColors.green
                            text: i18n.tr("Edit Profile")
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
                visible: !isPrivate
                width: !isPrivate ? parent.width : 0
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.gu(0.5)
                y: !isPrivate ? units.gu(2) : 0

                Rectangle {
                    width: parent.width
                    height: units.gu(0.17)
                    color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
                }

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                    spacing: (parent.width-units.gu(20))/4

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
                            name: "location"
                            color: current_user_section == 2 ? "#003569" : UbuntuColors.darkGrey
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                next_max_id = 0
                                instagram.getGeoMedia(usernameId)
                                current_user_section = 2
                                viewLoader.sourceComponent = geoviewComponent
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
                                instagram.getUserTags(usernameId)
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
                visible: !isPrivate && !isEmpty
                width: !isPrivate && !isEmpty ? parent.width : 0
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

                icon: true
                iconName: "stock_image"

                title: current_user_section == 3 ? i18n.tr("No Photos Yet") : ""

                description: current_user_section == 3 ? "" : i18n.tr("No photos or videos yet!")
            }

            Rectangle {
                visible: isPrivate ? true : false
                width: isPrivate ? parent.width : 0
                height: isPrivate ? units.gu(0.17) : 0
                color: Qt.lighter(UbuntuColors.lightGrey, 1.1)
            }

            EmptyBox {
                visible: isPrivate
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                icon: true
                iconName: "lock"
                iconColor: UbuntuColors.darkGrey

                description: i18n.tr("This account is private.")
                description2: i18n.tr("Follow to see their photos and videos.")
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

        Column {
            spacing: units.gu(4)
            x: units.gu(1)
            y: units.gu(1)
            width: viewLoader.width

            Repeater {
                model: userPhotosModel

                UserListFeedDelegate {
                    id: entry_column_photos
                    thismodel: userPhotosModel
                }
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

                Item {
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width

                    Image {
                        property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

                        id: feed_image
                        width: parent.width
                        height: width
                        source: bestImage.url
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        clip: true
                        asynchronous: true
                        cache: true
                        smooth: true
                    }
                    Icon {
                        visible: media_type == 2
                        width: units.gu(3)
                        height: width
                        name: "camcorder"
                        color: "#ffffff"
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(1)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(1)
                    }

                    Item {
                        width: activity2.width
                        height: width
                        anchors.centerIn: parent
                        opacity: feed_image.status == Image.Loading

                        Behavior on opacity {
                            UbuntuNumberAnimation {
                                duration: UbuntuAnimation.SlowDuration
                            }
                        }

                        ActivityIndicator {
                            id: activity2
                            running: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: id});
                        }
                    }
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

                Item {
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width

                    Image {
                        property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

                        id: feed_image
                        width: parent.width
                        height: width
                        source: bestImage.url
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        clip: true
                        asynchronous: true
                        cache: true
                        smooth: true
                    }
                    Icon {
                        visible: media_type == 2
                        width: units.gu(3)
                        height: width
                        name: "camcorder"
                        color: "#ffffff"
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(2)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(2)
                    }

                    Item {
                        width: activity2.width
                        height: width
                        anchors.centerIn: parent
                        opacity: feed_image.status == Image.Loading

                        Behavior on opacity {
                            UbuntuNumberAnimation {
                                duration: UbuntuAnimation.SlowDuration
                            }
                        }

                        ActivityIndicator {
                            id: activity2
                            running: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: id});
                        }
                    }
                }
            }
        }
    }

    Component {
        id: geoviewComponent

        Grid {
            columns: 3
            spacing: units.gu(0.1)

            Repeater {
                model: userGeoPhotosModel

                Item {
                    width: (viewLoader.width-units.gu(0.1))/3
                    height: width

                    Image {
                        id: feed_image
                        width: parent.width
                        height: width
                        source: display_url
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        clip: true
                        asynchronous: true
                        cache: true
                        smooth: true
                    }

                    Item {
                        width: activity2.width
                        height: width
                        anchors.centerIn: parent
                        opacity: feed_image.status == Image.Loading

                        Behavior on opacity {
                            UbuntuNumberAnimation {
                                duration: UbuntuAnimation.SlowDuration
                            }
                        }

                        ActivityIndicator {
                            id: activity2
                            running: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("SinglePhoto.qml"), {photoId: media_id});
                        }
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onUserTimeLineDataReady: {
            var data = JSON.parse(answer);
            userTimeLineDataFinished(data);
        }
        onUsernameDataReady: {
            var data = JSON.parse(answer);
            usernameDataFinished(data);
        }
        onUserTagsDataReady: {
            var data = JSON.parse(answer);
            userTagDataFinished(data);
        }
        onGeoMediaDataReady: {
            var data = JSON.parse(answer);
            userGeoDataFinished(data);
        }
        onSearchUsernameDataReady: {
            var data = JSON.parse(answer);
            usernameId = data.user.pk;

            if (usernameId == my_usernameId) {
                selfProfile = true

                getUsernameFeed();
            } else {
                selfProfile = false

                instagram.userFriendship(usernameId);
            }

            getUsernameInfo();
        }
        onUserFriendshipDataReady: {
            var data = JSON.parse(answer);

            if (!data.following && data.is_private) {
                isPrivate = true
            } else {
                isPrivate = false

                getUsernameFeed();
            }

            followingButton.visible = data.following
            unfollowingButton.visible = !data.following && !data.outgoing_request && !data.blocking
            requestedButton.visible = data.outgoing_request
            unBlockButton.visible = data.blocking
        }
    }

    Connections{
        target: instagram
        onFollowDataReady: {
            if (usernameId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
        onUnFollowDataReady: {
            if (usernameId == latest_follow_request) {
                var data = JSON.parse(answer);
                followDataFinished(data);
            }
        }
        onUnBlockDataReady: {
            var data = JSON.parse(answer);

            if (data.status == "ok" && !data.friendship_status.blocking) {
                followingButton.visible = false
                unfollowingButton.visible = true
                requestedButton.visible = false
                unBlockButton.visible = false
            }
        }
    }

    BottomMenu {
        id: bottomMenu
        width: parent.width
    }
}
