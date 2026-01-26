import QtQuick 2.12
import "../Constants"
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.DownloadManager 1.2

import ".."
import "../Media"

import "../../js/Storage.js" as Storage
import "../../js/Helper.js" as Helper
import "../../js/Scripts.js" as Scripts

ListItem {
    id: listFeedDelegate
    
    height: list_type === 'suggested_users' ?
                suggestionsPanelLoader.height + units.gu(4) :
                list_type === 'media_entry' ?
                    mediaEntryLoader.height + units.gu(2) :
                    list_type === 'stories_feed' ?
                        storiesFeedTrayLoader.height :
                        0

    divider.visible: false

    property var currentDelegatePage: pageLayout.primaryPage
    property var last_deleted_media
    property var thismodel

    // Feed Actions Popup Component
    Component {
        id: popoverComponent
        FeedActionsPopup {
            id: popoverElement
            width: parent.width
            currentDelegatePage: listFeedDelegate.currentDelegatePage
            downloadComponent: downloadComponent

            onOpenEditClicked: {
                pageLayout.pushToCurrent(currentDelegatePage, PagesConstants.edit_media, {mediaId: id})
            }

            onDeleteMediaClicked: {
                last_deleted_media = index
                instagram.deleteMedia(id)
            }

            onEnableCommentsClicked: {
                instagram.enableMediaComments(id)
            }

            onDisableCommentsClicked: {
                instagram.disableMediaComments(id)
            }

            onRemoveTagClicked: {
                last_deleted_media = index
                instagram.removeSelftag(id)
            }

            onCopyLinkClicked: {
                var share_url = "https://instagram.com/p/" + code
                Clipboard.push(share_url)
            }

            onDownloadMediaClicked: {
                var singleDownload = downloadComponent.createObject(mainView)
                singleDownload.contentType = ContentType.Pictures
                singleDownload.download(images_obj.candidates[0].url)
            }
        }
    }

    // Instagram API Response Handlers
    Connections {
        target: instagram
        
        onMediaDeleted: {
            if (index == last_deleted_media) {
                var data = JSON.parse(answer)
                if (data.did_delete) {
                    thismodel.remove(index)
                    if (thismodel.count == 0) {
                        pageLayout.removePages(currentDelegatePage)
                    }
                }
            }
        }
        
        onRemoveSelftagDone: {
            if (index == last_deleted_media) {
                var data = JSON.parse(answer)
                if (data.status == "ok") {
                    thismodel.remove(index)
                    if (thismodel.count == 0) {
                        pageLayout.removePages(currentDelegatePage)
                    }
                }
            }
        }
        
        onEnableMediaCommentsDataReady: {
            var data = JSON.parse(answer)
            if (data.status == "ok") {
                thismodel.get(index).comments_disabled = false
            }
        }
        
        onDisableMediaCommentsDataReady: {
            var data = JSON.parse(answer)
            if (data.status == "ok") {
                thismodel.get(index).comments_disabled = true
            }
        }
    }

    Loader {
        id: mediaEntryLoader
        width: parent.width
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'media_entry'
        active: list_type === 'media_entry'

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
        active: list_type === 'suggested_users'
        asynchronous: true

        sourceComponent: SuggestionsPanel {
            suggestionsModel: homeSuggestionsModel
            width: parent.width
        }
    }

    Loader {
        id: storiesFeedTrayLoader
        width: parent.width
        height: list_type === 'stories_feed' && storiesFeedTrayLoader.item.checkVisible() ? (width/5 + units.gu(3)) : 0
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'stories_feed'
        active: list_type === 'stories_feed'
        asynchronous: true

        sourceComponent: StoriesTray {
            id: storiesFeedTray
            anchors {
                fill: parent
            }
        }
    }
}
