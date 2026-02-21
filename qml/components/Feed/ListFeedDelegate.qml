import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.DownloadManager 1.2

import ".."
import "../Media"

import "../../js/Storage.js" as Storage
import "../../js/Scripts.js" as Scripts

ListItem {
    id: listFeedDelegate

    property var currentPage: pageLayout.primaryPage
    property var currentModel
    property var suggestionsModel

    height: calculateHeight(list_type)

    function calculateHeight(list_type) {
        if (list_type === 'suggested_users') {
            return suggestionsPanelLoader.height + units.gu(4)
        }
        if (list_type === 'media_entry') {
            return mediaEntryLoader.height + units.gu(2)
        }
        if (list_type === 'stories_feed') {
            return storiesFeedTrayLoader.height
        }
        return 0
    }

    divider.visible: false

    Loader {
        id: mediaEntryLoader
        width: parent.width
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'media_entry'
        active: visible
        asynchronous: false

        sourceComponent: MediaEntry {
            width: parent.width
        }
    }

    Loader {
        id: suggestionsPanelLoader
        width: parent.width
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'suggested_users'
        active: visible
        asynchronous: true
    }

    Loader {
        id: storiesFeedTrayLoader
        width: parent.width
        height: list_type === 'stories_feed' && storiesFeedTrayLoader.item.checkVisible() ? units.gu(13) : 0
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'stories_feed'
        active: visible
        asynchronous: true

        sourceComponent: StoriesTray {
            id: storiesFeedTray
            anchors.fill: parent
        }
    }
}
