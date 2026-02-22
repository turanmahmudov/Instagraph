// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts
import "../js/DirectTypeTexts.js" as DirectTypeTexts

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
    id: directinboxpage

    property bool list_loading: false

    property bool isEmpty: false

    property string next_oldest_cursor_id: ""
    property bool more_available: true
    property bool next_coming: true
    property bool clear_models: true

    header: PageHeaderItem {
        title: i18n.tr("Direct")
        trailingActions: [
            Action {
                id: newDirectMessageAction
                text: i18n.tr("New Message")
                iconName: IconsConstants.mic
                onTriggered: {
                    pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.new_direct_message)
                }
            }
        ]
    }

    ListModel {
        id: directInboxModel
    }

    WorkerScript {
        id: directInboxWorker
        source: "../js/Workers/DirectInboxWorker.js"
    }

    ListView {
        id: directInboxList
        visible: !isEmpty
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: directinboxpage.header.bottom
        }
        onMovementEnded: {
            if (atYEnd && more_available && !next_coming) {
                getInbox(next_oldest_cursor_id)
            }
        }

        clip: true
        cacheBuffer: parent.height
        model: directInboxModel
        delegate: InboxThreadItem {
            width: parent.width
        }

        PullToRefresh {
            refreshing: list_loading && directInboxModel.count == 0
            onRefresh: {
                list_loading = true
                getInbox()
            }
        }
    }

    EmptyBox {
        visible: isEmpty
        width: parent.width
        anchors {
            top: directinboxpage.header.bottom
            horizontalCenter: parent.horizontalCenter
        }

        iconName: IconsConstants.icon_eaab

        title: i18n.tr("Welcome to Instagraph Direct!")
        description: i18n.tr("Tap the + icon to send a photo, video or message.")
    }

    Connections{
        target: instagram
        onInboxDataReady: {
            var data = JSON.parse(answer)
            inboxDataFinished(data)
        }
    }

    function getInbox(oldest_cursor_id)
    {
        list_loading = true

        clear_models = false
        if (!oldest_cursor_id) {
            directInboxModel.clear()
            next_oldest_cursor_id = ""
            clear_models = true
        }
        instagram.getInbox(oldest_cursor_id)
    }

    function inboxDataFinished(data) {
        if (!data || !data.inbox) return

        list_loading = false

        isEmpty = false
        if (data.inbox.threads.length === 0) {
            isEmpty = true
            return
        }

        if (next_oldest_cursor_id === data.inbox.oldest_cursor) return

        next_oldest_cursor_id = ""
        if (data.inbox.has_older === true) {
            next_oldest_cursor_id = data.inbox.oldest_cursor
        }

        more_available = data.inbox.has_older
        next_coming = true

        directInboxWorker.sendMessage(
            {
                items: data.inbox.threads,
                model: directInboxModel,
                clear: clear_models,
                activeUserId: activeUsernameId,
                typeTexts: DirectTypeTexts.getDirectTypeTexts()
            }
        )

        next_coming = false
    }

    Component.onCompleted: {
        getInbox()
    }
}
