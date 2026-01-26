import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.DownloadManager 1.2

import ".."

import "../../js/Storage.js" as Storage
import "../../js/Scripts.js" as Scripts

ActionsPopup {
    id: feedactionspopup

    // Signals to communicate actions to parent
    signal openEditClicked()
    signal deleteMediaClicked()
    signal enableCommentsClicked()
    signal disableCommentsClicked()
    signal removeTagClicked()
    signal copyLinkClicked()
    signal downloadMediaClicked()

    // Properties that should be set by parent
    property var currentDelegatePage: pageLayout.primaryPage
    property var downloadComponent

    // Check if current user owns this media
    property bool is_current_user: activeUsernameId === user.pk

    actions: ActionList {
        Action {
            visible: is_current_user
            enabled: visible
            text: i18n.tr("Edit")
            onTriggered: {
                PopupUtils.close(feedactionspopup)
                openEditClicked()
            }
        }
        Action {
            visible: is_current_user
            enabled: visible
            text: i18n.tr("Delete")
            onTriggered: {
                deleteMediaClicked()
            }
        }
        Action {
            visible: is_current_user && (typeof comments_disabled != 'undefined' && comments_disabled == true)
            enabled: visible
            text: i18n.tr("Turn On Commenting")
            onTriggered: {
                enableCommentsClicked()
                PopupUtils.close(feedactionspopup)
            }
        }
        Action {
            visible: is_current_user && (typeof comments_disabled == 'undefined' || (typeof comments_disabled != 'undefined' && comments_disabled == false))
            enabled: visible
            text: i18n.tr("Turn Off Commenting")
            onTriggered: {
                disableCommentsClicked()
                PopupUtils.close(feedactionspopup)
            }
        }
        Action {
            visible: photo_of_you
            enabled: visible
            text: i18n.tr("Remove Tag")
            onTriggered: {
                removeTagClicked()
                PopupUtils.close(feedactionspopup)
            }
        }
        Action {
            visible: !user.is_private && code
            enabled: visible
            text: i18n.tr("Copy Link")
            onTriggered: {
                copyLinkClicked()
                PopupUtils.close(feedactionspopup)
            }
        }
        Action {
            visible: true
            enabled: true
            text: i18n.tr("Download Media")
            onTriggered: {
                downloadMediaClicked()
                PopupUtils.close(feedactionspopup)
            }
        }
    }
}
