import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

ListItem {
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

    Component {
        id: popoverComponent
        ActionSelectionPopover {
            id: popoverElement
            width: parent.width
            delegate: ListItem {
                visible: action.visible
                width: parent.width
                height: action.visible ? entry_column.height + units.gu(4) : 0

                Column {
                    id: entry_column
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: units.gu(2)
                    }
                    spacing: units.gu(1)
                    width: parent.width - units.gu(4)

                    Label {
                        width: parent.width
                        text: action.text
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                    }
                }
            }
            actions: ActionList {
                  Action {
                      visible: activeUsernameId == user.pk
                      enabled: activeUsernameId == user.pk
                      text: i18n.tr("Edit")
                      onTriggered: {
                          PopupUtils.close(popoverElement);
                          pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/EditMediaPage.qml"), {mediaId: id});
                      }
                  }
                  Action {
                      visible: activeUsernameId == user.pk
                      enabled: activeUsernameId == user.pk
                      text: i18n.tr("Delete")
                      onTriggered: {
                          last_deleted_media = index
                          instagram.deleteMedia(id);
                      }
                  }
                  Action {
                      visible: activeUsernameId == user.pk && (typeof comments_disabled != 'undefined' && comments_disabled == true)
                      enabled: activeUsernameId == user.pk && (typeof comments_disabled != 'undefined' && comments_disabled == true)
                      text: i18n.tr("Turn On Commenting")
                      onTriggered: {
                            instagram.enableMediaComments(id)
                      }
                  }
                  Action {
                      visible: activeUsernameId == user.pk && (typeof comments_disabled == 'undefined' || (typeof comments_disabled != 'undefined' && comments_disabled == false))
                      enabled: activeUsernameId == user.pk && (typeof comments_disabled == 'undefined' || (typeof comments_disabled != 'undefined' && comments_disabled == false))
                      text: i18n.tr("Turn Off Commenting")
                      onTriggered: {
                          instagram.disableMediaComments(id)
                      }
                  }
                  Action {
                      visible: photo_of_you
                      enabled: photo_of_you
                      text: i18n.tr("Remove Tag")
                      onTriggered: {
                          last_deleted_media = index
                          instagram.removeSelftag(id);
                      }
                  }
                  Action {
                      visible: !user.is_private && code
                      enabled: !user.is_private && code
                      text: i18n.tr("Copy Link")
                      onTriggered: {
                          var share_url = "https://instagram.com/p/"+code;
                          Clipboard.push(share_url);
                          PopupUtils.close(popoverElement);
                      }
                  }
                  Action {
                      visible: true
                      enabled: true
                      text: i18n.tr("Download Media")
                      onTriggered: {
                          var singleDownload = downloadComponent.createObject(mainView)
                          singleDownload.contentType = ContentType.Pictures
                          singleDownload.download(images_obj.candidates[0].url)
                          PopupUtils.close(popoverElement);
                      }
                  }
            }

            Connections {
                target: instagram
                onMediaDeleted: {
                    if (index == last_deleted_media) {
                        var data = JSON.parse(answer);
                        if (data.did_delete) {
                            thismodel.remove(index)
                            if (thismodel.count == 0) {
                                pageLayout.removePages(currentDelegatePage);
                            }
                        }
                    }
                }
                onRemoveSelftagDone: {
                    if (index == last_deleted_media) {
                        var data = JSON.parse(answer);
                        if (data.status == "ok") {
                            thismodel.remove(index)
                            if (thismodel.count == 0) {
                                pageLayout.removePages(currentDelegatePage);
                            }
                        }
                    }
                }
                onEnableMediaCommentsDataReady: {
                    var data = JSON.parse(answer)
                    if (data.status == "ok") {
                        thismodel.get(index).comments_disabled = false
                        PopupUtils.close(popoverElement);
                    }
                }
                onDisableMediaCommentsDataReady: {
                    var data = JSON.parse(answer)
                    if (data.status == "ok") {
                        thismodel.get(index).comments_disabled = true
                        PopupUtils.close(popoverElement);
                    }
                }
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
