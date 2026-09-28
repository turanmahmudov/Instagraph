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
import "../components/Actions"
import "../components/Direct"
import "../viewmodels"

PageItem {
    id: directthreadpage

    property var threadId

    header: PageHeaderItem {
        title: threadViewModel.threadTitle
    }

    DirectThreadViewModel {
        id: threadViewModel
        threadId: directthreadpage.threadId
        onMessageSent: addMessageItem.clearTextField()
    }

    property alias list_loading: threadViewModel.isLoading
    property alias threadUsers: threadViewModel.threadUsers

    Component.onCompleted: {
        threadViewModel.loadThread();
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
            if (atYBeginning) {
                threadViewModel.loadMore();
            }
        }
        verticalLayoutDirection: ListView.BottomToTop
        clip: true
        cacheBuffer: parent.height * 3
        model: threadViewModel.threadModel
        delegate: ListItem {
            id: directThreadDelegate
            divider.visible: false
            height: layout.height

            property bool outgoing_message: user_id == activeUsernameId || (user_id != activeUsernameId && item_type == "action_log")
            property bool show_user_image: (user_id != activeUsernameId && index == 0) || (user_id != activeUsernameId && index != 0 && threadViewModel.threadModel.get(index - 1).user_id !== user_id)

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
                                return unsupportedComponent;
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
                            userId: user_id
                            users: directthreadpage.threadUsers || {}
                        }
                    }

                    Component {
                        id: mediaComponent
                        DirectThreadMediaMessage {
                            itemMaxWidth: directThreadDelegate.item_max_width
                            mediaImage: (media && media.image_versions2 && media.image_versions2.candidates) ? media.image_versions2.candidates[0] : undefined
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
                        id: unsupportedComponent
                        Label {
                            height: implicitHeight + units.gu(2.5)
                            verticalAlignment: Text.AlignVCenter
                            text: i18n.tr("Unsupported message")
                            fontSize: "small"
                            color: styleApp.common.text2Color
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

        enabled: !threadViewModel.isSending

        onSendMessageClicked: threadViewModel.sendMessage(text)
        onSendLikeClicked: threadViewModel.sendLike()
    }
}
