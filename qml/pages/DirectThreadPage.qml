// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"
import "../components/Direct"

PageItem {
    id: directthreadpage

    property bool list_loading: false
    property bool is_sending: false

    property var threadId

    property var threadUsers: []

    property string next_oldest_cursor_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    property bool firstLoad: true

    property string sentMessage: ""

    header: PageHeaderItem {
        title: i18n.tr("Direct")
    }

    ListModel {
        id: directThreadModel
    }

    WorkerScript {
        id: directThreadWorker
        source: "../js/Workers/DirectThreadWorker.js"
        onMessage: directThreadModel.insert(0, messageObject)
    }

    Component.onCompleted: {
        firstLoad = true;
        directThread();
    }

    function directThread(oldest_cursor_id) {
        clear_models = false;
        if (!oldest_cursor_id) {
            directThreadModel.clear();
            next_oldest_cursor_id = 0;
            clear_models = true;
        }
        list_loading = true;
        instagram.getDirectThread(threadId, oldest_cursor_id);
    }

    function sendMessage(text) {
        // Validate input - don't send empty messages
        const trimmedText = text.trim();
        if (!trimmedText || is_sending) {
            return;
        }

        is_sending = true;
        sentMessage = trimmedText;

        const recip_string = getRecipientsString(threadUsers);

        instagram.directMessage(recip_string, trimmedText, threadId);
    }

    function sendLike() {
        if (is_sending)
            return;
        is_sending = true;
        const recip_string = getRecipientsString({
            [threadId]: threadId
        });

        instagram.directLike(recip_string, threadId);
    }

    function directThreadFinished(data) {
        if (!data || !data.thread) {
            console.warn("Invalid thread data received");
            list_loading = false;
            return;
        }

        const thread = data.thread;

        if (firstLoad == true) {
            directthreadpage.header.title = thread.thread_title !== "" ? thread.thread_title : (thread.inviter ? thread.inviter.username : i18n.tr("Direct"));

            if (thread.users && thread.users.length > 0) {
                thread.users.forEach(user => {
                    threadUsers[user.pk] = user;
                });
            }

            // Mark Direct Thread Item Seen
            if (thread.items && thread.items.length > 0) {
                const thId = thread.thread_id;
                const thItemId = thread.items[0].item_id;
                instagram.markThreadSeen(thId, thItemId);
            }

            firstLoad = false;
        }

        if (next_oldest_cursor_id === thread.oldest_cursor) {
            list_loading = false;
            return;
        }

        next_oldest_cursor_id = thread.has_older === true ? thread.oldest_cursor : "";
        more_available = thread.has_older;
        next_coming = true;

        directThreadWorker.sendMessage({
            'obj': thread.items || [],
            'model': directThreadModel,
            'clear_model': clear_models,
            'insert': false
        });

        next_coming = false;
        list_loading = false;
    }

    function messagePostedFinished(data) {
        is_sending = false;

        if (!data || !data.payload) {
            console.warn("Failed to send message");
            return;
        }

        const items = [
            {
                "item_type": "text",
                "text": sentMessage,
                "user_id": parseInt(activeUsernameId),
                "item_id": data.payload.item_id
            }
        ];

        directThreadWorker.sendMessage({
            'obj': items,
            'model': directThreadModel,
            'clear_model': false,
            'insert': true
        });

        sentMessage = "";
        addMessageItem.clearTextField();
    }

    function likePostedFinished(data) {
        is_sending = false;

        if (!data || !data.payload) {
            console.warn("Failed to send like");
            return;
        }

        const items = [
            {
                "item_type": "like",
                "user_id": parseInt(activeUsernameId),
                "item_id": data.payload.item_id
            }
        ];

        directThreadWorker.sendMessage({
            'obj': items,
            'model': directThreadModel,
            'clear_model': false,
            'insert': true
        });
    }

    function getRecipientsString(recipients) {
        let recip_array = [];

        for (let i in recipients) {
            recip_array.push(`"${i}"`);
        }

        return recip_array.join(',');
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
                directThread(next_oldest_cursor_id);
            }
        }
        verticalLayoutDirection: ListView.BottomToTop
        clip: true
        cacheBuffer: parent.height * 3
        model: directThreadModel
        delegate: ListItem {
            id: directThreadDelegate
            divider.visible: false
            height: layout.height

            property bool outgoing_message: user_id == activeUsernameId || (user_id != activeUsernameId && item_type == "action_log")
            property bool show_user_image: (user_id != activeUsernameId && index == 0) || (user_id != activeUsernameId && index != 0 && directThreadModel.get(index - 1).user_id !== user_id)

            property var max_width: width - (outgoing_message ? 0 : units.gu(5))
            property var item_max_width: max_width * 3 / 4
            property var item_small_width: max_width / 3

            SlotsLayout {
                id: layout

                padding.leading: 0
                padding.trailing: 0
                padding.top: units.gu(0.2)
                padding.bottom: units.gu(0.2)

                mainSlot: Row {
                    id: label
                    spacing: units.gu(1)
                    width: max_width

                    layoutDirection: outgoing_message ? Qt.RightToLeft : Qt.LeftToRight

                    // Single Loader - switches component based on item_type
                    Loader {
                        id: messageLoader
                        asynchronous: true

                        sourceComponent: {
                            switch (item_type) {
                            case "text":
                                return textMessageComponent;
                            case "animated_media":
                                return animatedMediaComponent;
                            case "media_share":
                                return mediaShareComponent;
                            case "like":
                                return likeComponent;
                            case "action_log":
                                return actionLogComponent;
                            case "media":
                                return mediaComponent;
                            case "link":
                                return linkComponent;
                            case "placeholder":
                                return placeholderComponent;
                            case "reel_share":
                                return reelShareComponent;
                            case "story_share":
                                return storyShareComponent;
                            case "raven_media":
                                return ravenMediaComponent;
                            case "xma_media_share":
                                return xmaMediaShareComponent;
                            default:
                                return null;
                            }
                        }
                    }

                    // Component definitions
                    Component {
                        id: textMessageComponent
                        DirectThreadTextMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: animatedMediaComponent
                        DirectThreadAnimatedMessage {
                            isSticker: animated_media ? (animated_media.is_sticker || false) : false
                            isOutgoing: directThreadDelegate.outgoing_message
                            mediaImage: animated_media && animated_media.url ? animated_media : undefined
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: mediaShareComponent
                        DirectThreadMediaShareMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: likeComponent
                        DirectThreadLikeMessage {}
                    }

                    Component {
                        id: actionLogComponent
                        DirectThreadActionLogMessage {
                            userId: directThreadDelegate.user_id
                            users: directthreadpage.threadUsers || {}
                        }
                    }

                    Component {
                        id: mediaComponent
                        DirectThreadMediaMessage {
                            itemMaxWidth: directThreadDelegate.item_max_width
                            mediaImage: (directThreadDelegate.media && directThreadDelegate.media.image_versions2 && directThreadDelegate.media.image_versions2.candidates) ? directThreadDelegate.media.image_versions2.candidates[0] : undefined
                            isMedia: true
                        }
                    }

                    Component {
                        id: linkComponent
                        DirectThreadLinkMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: placeholderComponent
                        DirectThreadPlaceholderMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: reelShareComponent
                        DirectThreadReelShareMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                            itemSmallWidth: directThreadDelegate.item_small_width
                        }
                    }

                    Component {
                        id: storyShareComponent
                        DirectThreadStoryShareMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                            itemSmallWidth: directThreadDelegate.item_small_width
                        }
                    }

                    Component {
                        id: ravenMediaComponent
                        DirectThreadRavenMediaMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
                        }
                    }

                    Component {
                        id: xmaMediaShareComponent
                        DirectThreadXmaMediaShareMessage {
                            isOutgoing: directThreadDelegate.outgoing_message
                            itemMaxWidth: directThreadDelegate.item_max_width
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
                        source: {
                            if (user_id == activeUsernameId)
                                return '';
                            if (!threadUsers[user_id])
                                return '';
                            return threadUsers[user_id].profile_pic_url || '';
                        }
                    }

                    SlotsLayout.position: SlotsLayout.Leading
                }
            }
        }
    }

    AddMessageItem {
        id: addMessageItem
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(1)
        }

        enabled: !is_sending

        onSendMessageClicked: sendMessage(text)
        onSendLikeClicked: sendLike()
    }

    Connections {
        target: instagram
        onDirectThreadDataReady: {
            var data = JSON.parse(answer);
            directThreadFinished(data);
        }
        onDirectMessageDataReady: {
            var data = JSON.parse(answer);
            messagePostedFinished(data);
        }
        onDirectLikeDataReady: {
            var data = JSON.parse(answer);
            likePostedFinished(data);
        }
        onMarkThreadSeenDataReady: {}
    }
}
