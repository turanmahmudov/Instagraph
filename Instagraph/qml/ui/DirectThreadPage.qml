import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: directthreadpage

    property bool list_loading: false

    property var threadId

    property var threadUsers: []

    property string next_oldest_cursor_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool firstLoad: true

    header: PageHeader {
        title: i18n.tr("Direct")
    }

    function directThreadFinished(data) {
        if (firstLoad == true) {
            directthreadpage.header.title = data.thread.thread_title != "" ? data.thread.thread_title : data.thread.inviter.username;

            for (var j = 0; j < data.thread.users.length; j++) {
                threadUsers[data.thread.users[j].pk] = data.thread.users[j];
            }

            // Mark Direct Thread Item Seen
            var thId = data.thread.thread_id;
            var thItemId = data.thread.items[0].item_id;
            instagram.markDirectThreadItemSeen(thId, thItemId);
        }

        if (next_oldest_cursor_id == data.thread.oldest_cursor) {
            return false;
        } else {
            next_oldest_cursor_id = data.thread.has_older == true ? data.thread.oldest_cursor : "";
            more_available = data.thread.has_older;
            next_coming = true;

            for (var i = 0; i < data.thread.items.length; i++) {
                data.thread.items[i].ctext = data.thread.items[i].text;

                directThreadModel.append(data.thread.items[i]);
            }

            next_coming = false;
        }

        list_loading = false
    }

    function messagePostedFinished(data) {
        for (var j = 0; j < data.threads.length; j++) {
            var thread = data.threads[j];
            for (var i = 0; i < thread.items.length; i++) {
                thread.items[i].ctext = thread.items[i].text;
                directThreadModel.insert(0, thread.items[i]);
            }
        }

        addMessageField.text = '';
    }

    function likePostedFinished(data) {
        for (var j = 0; j < data.threads.length; j++) {
            var thread = data.threads[j];
            for (var i = 0; i < thread.items.length; i++) {
                thread.items[i].ctext = thread.items[i].text;
                directThreadModel.insert(0, thread.items[i]);
            }
        }
    }

    Component.onCompleted: {
        firstLoad = true;
        directThread();
    }

    function directThread(oldest_cursor_id)
    {
        clear_models = false
        if (!oldest_cursor_id) {
            directThreadModel.clear()
            next_oldest_cursor_id = 0
            clear_models = true
        }
        list_loading = true
        instagram.directThread(threadId, oldest_cursor_id);
    }

    function sendMessage(text)
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+i+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directMessage(recip_string, text, threadId);
    }

    function sendLike()
    {
        var recip_array = [];
        var recip_string = '';
        for (var i in threadUsers) {
            recip_array.push('"'+i+'"');
        }
        recip_string = recip_array.join(',');

        instagram.directLike(recip_string, threadId);
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: directthreadpage.header.bottom
        visible: instagram.busy || list_loading
    }

    ListModel {
        id: directThreadModel
        dynamicRoles: true
    }

    ListView {
        id: directThreadList
        anchors {
            left: parent.left
            right: parent.right
            bottom: addMessageItem.top
            bottomMargin: units.gu(1)
            top: directthreadpage.header.bottom
        }
        onMovementEnded: {
            if (atYBeginning && more_available && !next_coming) {
                directThread(next_oldest_cursor_id)
            }
        }
        verticalLayoutDirection: ListView.BottomToTop
        clip: true
        cacheBuffer: parent.height*2
        model: directThreadModel
        delegate: ListItem {
            id: directThreadDelegate
            divider.visible: false
            height: layout.height

            property bool outgoing_message: user_id == my_usernameId || (user_id != my_usernameId && item_type == "action_log")
            property bool show_user_image: (user_id != my_usernameId && index == 0) || (user_id != my_usernameId && index != 0 && directThreadModel.get(index-1).user_id != user_id)

            SlotsLayout {
                id: layout

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(0.2)
                padding.bottom: units.gu(0.2)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: parent.width - (outgoing_message ? 0 : units.gu(5))

                    layoutDirection: outgoing_message ? Qt.RightToLeft : Qt.LeftToRight

                    Loader {
                        id: messageLoader
                        sourceComponent: item_type == "text" ? textMessageComponent :
                                                            item_type == "like" ? likeMessageComponent :
                                                            item_type == "media" ? mediaMessageComponent :
                                                            item_type == "media_share" ? mediaShareMessageComponent :
                                                            item_type == "reel_share" ? reelShareMessageComponent :
                                                            item_type == "story_share" ? storyShareMessageComponent :
                                                            item_type == "action_log" ? actionLogMessageComponent :
                                                            item_type == "placeholder" ? placeholderMessageComponent :
                                                            item_type == "link" ? linkMessageComponent : textMessageComponent
                    }

                    // Text
                    Component {
                        id: textMessageComponent

                        Rectangle {
                            width: myText.width + units.gu(3)
                            height: myText.height + units.gu(2.5)
                            color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                            radius: units.gu(2)
                            border.width: units.gu(0.1)
                            border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                            Label {
                                id: myText
                                wrapMode: Text.WordWrap
                                width: Math.min(contentWidth, label.width*3/4)
                                anchors.centerIn: parent
                                text: ctext
                            }
                        }
                    }

                    // Like
                    Component {
                        id: likeMessageComponent

                        Icon {
                            width: units.gu(4)
                            height: units.gu(4)
                            name: "like"
                            color: UbuntuColors.red
                        }
                    }

                    // Media
                    Component {
                        id: mediaMessageComponent

                        Image {
                            width: label.width*3/4
                            height: width/media.image_versions2.candidates[0].width*media.image_versions2.candidates[0].height
                            source: item_type == "media" ? media.image_versions2.candidates[0].url : ''
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(width,height)
                            smooth: true
                            clip: true
                        }
                    }

                    // Media Share
                    Component {
                        id: mediaShareMessageComponent

                        Column {
                            spacing: units.gu(0.4)

                            Rectangle {
                                width: label.width*3/4
                                height: mediShareColumn.height + units.gu(2.5)
                                color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                                radius: units.gu(2)
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                                Column {
                                    id: mediShareColumn
                                    width: parent.width
                                    spacing: units.gu(1)

                                    Item {
                                        width: parent.width
                                        height: units.gu(0.1)
                                    }

                                    Row {
                                        x: units.gu(1)
                                        width: parent.width - units.gu(2)
                                        spacing: units.gu(1)
                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                        }

                                        CircleImage {
                                            width: units.gu(4)
                                            height: width
                                            source: typeof media_share.user != 'undefined' && typeof media_share.user.profile_pic_url != 'undefined' ? media_share.user.profile_pic_url : "../images/not_found_user.jpg"

                                            MouseArea {
                                                anchors {
                                                    fill: parent
                                                }
                                                onClicked: {
                                                    pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: media_share.user.pk});
                                                }
                                            }
                                        }

                                        Column {
                                            spacing: units.gu(0.2)
                                            width: parent.width - units.gu(4)
                                            anchors {
                                                verticalCenter: parent.verticalCenter
                                            }

                                            Label {
                                                text: typeof media_share.user != 'undefined' && typeof media_share.user.username != 'undefined' ? media_share.user.username : ''
                                                font.weight: Font.DemiBold
                                                wrapMode: Text.WordWrap

                                                MouseArea {
                                                    anchors {
                                                        fill: parent
                                                    }
                                                    onClicked: {
                                                        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: media_share.user.pk});
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    FeedImage {
                                        id: feed_image
                                        width: parent.width
                                        height: width/bestImage.width*bestImage.height
                                        source: bestImage.url
                                        smooth: true
                                        clip: true

                                        property var bestImage: typeof media_share.carousel_media !== 'undefined' && media_share.carousel_media.length > 0 ?
                                                                    Helper.getBestImage(media_share.carousel_media[0].image_versions2.candidates, parent.width) :
                                                                    Helper.getBestImage(media_share.image_versions2.candidates, parent.width)
                                    }

                                    Item {
                                        width: parent.width
                                        height: units.gu(0.1)
                                    }
                                }

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }

                            Rectangle {
                                visible: typeof media_share.text != 'undefined'
                                width: typeof media_share.text != 'undefined' ? myMediaShareText.width + units.gu(3) : 0
                                height: typeof media_share.text != 'undefined' ? myMediaShareText.height + units.gu(2.5) : 0
                                color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                                radius: units.gu(2)
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                                Label {
                                    id: myMediaShareText
                                    wrapMode: Text.WordWrap
                                    width: Math.min(contentWidth, label.width*3/4)
                                    anchors.centerIn: parent
                                    text: typeof media_share.text != 'undefined' ? media_share.text : ''
                                }

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }
                        }
                    }

                    // Reel Share
                    Component {
                        id: reelShareMessageComponent

                        Column {
                            id: reelShareColumn
                            spacing: units.gu(0.4)
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                Rectangle {
                                    visible: outgoing_message == false
                                    width: outgoing_message == false ? units.gu(0.1) : 0
                                    height: Math.max(parent.height, units.gu(5))
                                    color: UbuntuColors.lightGrey
                                }
                                Item {
                                    visible: outgoing_message == false
                                    width: outgoing_message == false ? units.gu(0.5) : 0
                                    height: outgoing_message == false ? units.gu(1) : 0
                                }

                                Column {
                                    spacing: units.gu(0.1)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Label {
                                        text: reel_share.type == 'mention' ? (outgoing_message ? i18n.tr("You mentioned their in a story") : i18n.tr("Mentied you in a story")) :
                                                                             reel_share.type == 'reply' ? (outgoing_message ? i18n.tr("You replied to their story") : i18n.tr("Replied to your story")) : i18n.tr("UNKNOWN")
                                        fontSize: "small"
                                        color: UbuntuColors.darkGrey
                                        font.weight: Font.Light
                                        wrapMode: Text.WordWrap
                                        width: contentWidth

                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Loader {
                                        active: typeof reel_share.media.image_versions2 != 'undefined'
                                        sourceComponent: Image {
                                            width: label.width/3
                                            height: width/reel_share.media.image_versions2.candidates[0].width*reel_share.media.image_versions2.candidates[0].height
                                            source: reel_share.media.image_versions2.candidates[0].url
                                            fillMode: Image.PreserveAspectCrop
                                            sourceSize: Qt.size(width,height)
                                            smooth: true
                                            clip: true
                                        }

                                        Component.onCompleted: {
                                            if (outgoing_message) {
                                                anchors.right = parent.right
                                            }
                                        }
                                    }
                                }

                                Item {
                                    visible: outgoing_message
                                    width: outgoing_message ? units.gu(0.5) : 0
                                    height: outgoing_message ? units.gu(1) : 0
                                }
                                Rectangle {
                                    visible: outgoing_message
                                    width: outgoing_message ? units.gu(0.1) : 0
                                    height: Math.max(parent.height, units.gu(5))
                                    color: UbuntuColors.lightGrey
                                }

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }

                            Rectangle {
                                visible: typeof reel_share.text != 'undefined' && reel_share.text != ''
                                width: typeof reel_share.text != 'undefined' && reel_share.text != '' ? myReelText.width + units.gu(3) : 0
                                height: typeof reel_share.text != 'undefined' && reel_share.text != '' ? myReelText.height + units.gu(2.5) : 0
                                color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                                radius: units.gu(2)
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                                Label {
                                    id: myReelText
                                    wrapMode: Text.WordWrap
                                    width: Math.min(contentWidth, label.width*3/4)
                                    anchors.centerIn: parent
                                    text: typeof reel_share.text != 'undefined' && reel_share.text != '' ? reel_share.text : ''
                                }

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }
                        }
                    }

                    // Story Share
                    Component {
                        id: storyShareMessageComponent

                        Column {
                            spacing: units.gu(0.4)

                            Loader {
                                sourceComponent: story_share.is_linked == false ? noStoryShareComponent : storyShareComponent

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }

                            Component {
                                id: storyShareComponent

                                Row {
                                    Rectangle {
                                        visible: outgoing_message == false
                                        width: outgoing_message == false ? units.gu(0.1) : 0
                                        height: Math.max(parent.height, units.gu(5))
                                        color: UbuntuColors.lightGrey
                                    }
                                    Item {
                                        visible: outgoing_message == false
                                        width: outgoing_message == false ? units.gu(0.5) : 0
                                        height: outgoing_message == false ? units.gu(1) : 0
                                    }

                                    Column {
                                        spacing: units.gu(0.1)
                                        anchors.verticalCenter: parent.verticalCenter

                                        Label {
                                            text: outgoing_message ? i18n.tr("You sent %1's story.").arg(story_share.media.user.username) : i18n.tr("Sent %1's story.").arg(story_share.media.user.username)
                                            fontSize: "small"
                                            color: UbuntuColors.darkGrey
                                            font.weight: Font.Light
                                            wrapMode: Text.WordWrap
                                            width: contentWidth

                                            horizontalAlignment: Text.AlignRight
                                        }

                                        Image {
                                            width: label.width/3
                                            height: width/story_share.media.image_versions2.candidates[0].width*story_share.media.image_versions2.candidates[0].height
                                            source: story_share.media.image_versions2.candidates[0].url
                                            fillMode: Image.PreserveAspectCrop
                                            sourceSize: Qt.size(width,height)
                                            smooth: true
                                            clip: true

                                            Component.onCompleted: {
                                                if (outgoing_message) {
                                                    anchors.right = parent.right
                                                }
                                            }
                                        }
                                    }

                                    Item {
                                        visible: outgoing_message
                                        width: outgoing_message ? units.gu(0.5) : 0
                                        height: outgoing_message ? units.gu(1) : 0
                                    }
                                    Rectangle {
                                        visible: outgoing_message
                                        width: outgoing_message ? units.gu(0.1) : 0
                                        height: Math.max(parent.height, units.gu(5))
                                        color: UbuntuColors.lightGrey
                                    }

                                    Component.onCompleted: {
                                        if (outgoing_message) {
                                            anchors.right = parent.right
                                        }
                                    }
                                }
                            }

                            Component {
                                id: noStoryShareComponent

                                Row {
                                    Rectangle {
                                        visible: outgoing_message == false
                                        width: outgoing_message == false ? units.gu(0.1) : 0
                                        height: Math.max(parent.height, units.gu(5))
                                        color: UbuntuColors.lightGrey
                                    }
                                    Item {
                                        visible: outgoing_message == false
                                        width: outgoing_message == false ? units.gu(0.5) : 0
                                        height: outgoing_message == false ? units.gu(1) : 0
                                    }

                                    Column {
                                        spacing: units.gu(0.1)
                                        anchors.verticalCenter: parent.verticalCenter

                                        Label {
                                            text: Helper.formatString(story_share.title)
                                            fontSize: "small"
                                            color: UbuntuColors.darkGrey
                                            font.weight: Font.Light
                                            wrapMode: Text.WordWrap
                                            textFormat: Text.RichText
                                            onLinkActivated: {
                                                Scripts.linkClick(link)
                                            }

                                            horizontalAlignment: Text.AlignRight
                                        }

                                        Label {
                                            text: story_share.message
                                            fontSize: "small"
                                            color: UbuntuColors.darkGrey
                                            font.weight: Font.Light
                                            wrapMode: Text.WordWrap

                                            horizontalAlignment: Text.AlignRight
                                        }
                                    }

                                    Item {
                                        visible: outgoing_message
                                        width: outgoing_message ? units.gu(0.5) : 0
                                        height: outgoing_message ? units.gu(1) : 0
                                    }
                                    Rectangle {
                                        visible: outgoing_message
                                        width: outgoing_message ? units.gu(0.1) : 0
                                        height: Math.max(parent.height, units.gu(5))
                                        color: UbuntuColors.lightGrey
                                    }

                                    Component.onCompleted: {
                                        if (outgoing_message) {
                                            anchors.right = parent.right
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                visible: typeof story_share.text != 'undefined' && story_share.text != ''
                                width: typeof story_share.text != 'undefined' && story_share.text != '' ? myStoryText.width + units.gu(3) : 0
                                height: typeof story_share.text != 'undefined' && story_share.text != '' ? myStoryText.height + units.gu(2.5) : 0
                                color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                                radius: units.gu(2)
                                border.width: units.gu(0.1)
                                border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                                Label {
                                    id: myStoryText
                                    wrapMode: Text.WordWrap
                                    width: Math.min(contentWidth, label.width*3/4)
                                    anchors.centerIn: parent
                                    text: typeof story_share.text != 'undefined' && story_share.text != '' ? story_share.text : ''
                                }

                                Component.onCompleted: {
                                    if (outgoing_message) {
                                        anchors.right = parent.right
                                    }
                                }
                            }
                        }
                    }

                    // Action Log
                    Component {
                        id: actionLogMessageComponent

                        Row {
                            width: units.gu(5)
                            height: units.gu(5)
                            spacing: units.gu(0.5)

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                width: units.gu(2)
                                height: units.gu(2)
                                name: "like"
                                color: UbuntuColors.red
                            }

                            CircleImage {
                                anchors.verticalCenter: parent.verticalCenter
                                width: units.gu(2)
                                height: width
                                source: user_id != my_usernameId ? threadUsers[user_id].profile_pic_url : ''
                            }
                        }
                    }

                    // Link
                    Component {
                        id: linkMessageComponent

                        Rectangle {
                            width: label.width*3/4
                            height: linkColumn.height + units.gu(2.5)
                            color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                            radius: units.gu(2)
                            border.width: units.gu(0.1)
                            border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                            Column {
                                id: linkColumn
                                width: parent.width

                                spacing: units.gu(1)

                                Item {
                                    width: parent.width
                                    height: units.gu(0.1)
                                }

                                Label {
                                    anchors {
                                        left: parent.left
                                        leftMargin: units.gu(1.5)
                                        right: parent.right
                                        rightMargin: units.gu(1.5)
                                    }
                                    width: parent.width - units.gu(2)
                                    text: Helper.makeLink(link.text)
                                    color: UbuntuColors.darkGrey
                                    wrapMode: Text.WordWrap
                                    textFormat: Text.RichText
                                    font.weight: Font.DemiBold
                                    onLinkActivated: {
                                        Scripts.linkClick(link)
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: units.gu(0.1)
                                    color: UbuntuColors.lightGrey
                                }

                                Label {
                                    anchors {
                                        left: parent.left
                                        leftMargin: units.gu(1.5)
                                        right: parent.right
                                        rightMargin: units.gu(1.5)
                                    }
                                    width: parent.width - units.gu(2)
                                    text: link.link_context.link_title
                                    color: UbuntuColors.darkGrey
                                    wrapMode: Text.WordWrap
                                }

                                Label {
                                    anchors {
                                        left: parent.left
                                        leftMargin: units.gu(1.5)
                                        right: parent.right
                                        rightMargin: units.gu(1.5)
                                    }
                                    width: parent.width - units.gu(2)
                                    text: link.link_context.link_summary
                                    fontSize: "small"
                                    color: UbuntuColors.darkGrey
                                    font.weight: Font.Light
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    // Placeholder
                    Component {
                        id: placeholderMessageComponent

                        Rectangle {
                            width: placeholderColumn.width + units.gu(3)
                            height: placeholderColumn.height + units.gu(2.5)
                            color: outgoing_message ? Qt.lighter(UbuntuColors.lightGrey, 1.2) : "#ffffff"
                            radius: units.gu(2)
                            border.width: units.gu(0.1)
                            border.color: Qt.lighter(UbuntuColors.lightGrey, 1.2)

                            Column {
                                id: placeholderColumn
                                spacing: units.gu(0.4)
                                anchors.centerIn: parent

                                Label {
                                    text: placeholder.title
                                    fontSize: "small"
                                    font.weight: Font.DemiBold
                                    color: UbuntuColors.darkGrey
                                    wrapMode: Text.WordWrap
                                    width: Math.min(contentWidth, label.width*3/4)
                                }

                                Label {
                                    text: placeholder.message
                                    fontSize: "small"
                                    color: UbuntuColors.darkGrey
                                    font.weight: Font.Light
                                    wrapMode: Text.WordWrap
                                    width: Math.min(contentWidth, label.width*3/4)
                                }
                            }
                        }
                    }

                }

                Item {
                    id: otherUserPhotoItem
                    width: outgoing_message ? 0 : units.gu(5)
                    height: units.gu(5)

                    CircleImage {
                        id: otherUserPhoto
                        visible: show_user_image
                        width: parent.width
                        height: width
                        source: user_id != my_usernameId ? threadUsers[user_id].profile_pic_url : ''
                    }

                    anchors.bottom: parent.bottom
                    SlotsLayout.position: SlotsLayout.Leading
                    SlotsLayout.overrideVerticalPositioning: true
                }
            }
        }
    }

    Item {
        id: addMessageItem
        height: units.gu(5)
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
        onDirectThreadReady: {
            var data = JSON.parse(answer);
            directThreadFinished(data);
        }
        onDirectMessageReady: {
            var data = JSON.parse(answer);
            messagePostedFinished(data);
        }
        onDirectLikeReady: {
            var data = JSON.parse(answer);
            likePostedFinished(data);
        }
        onMarkDirectThreadItemSeenReady: {

        }
    }
}
