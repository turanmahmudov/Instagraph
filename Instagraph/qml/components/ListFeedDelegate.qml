import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
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

    property var last_deleted_media
    property var thismodel

    Component {
        id: popoverComponent
        ActionSelectionPopover {
            id: popoverElement
            delegate: ListItem {
                visible: action.visible
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
                        text: action.text
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                    }
                }
            }
            actions: ActionList {
                  Action {
                      visible: my_usernameId == user.pk
                      enabled: my_usernameId == user.pk
                      text: i18n.tr("Edit")
                      onTriggered: {
                          PopupUtils.close(popoverElement);
                          pageStack.push(Qt.resolvedUrl("../ui/EditMediaPage.qml"), {mediaId: id});
                      }
                  }
                  Action {
                      visible: my_usernameId == user.pk
                      enabled: my_usernameId == user.pk
                      text: i18n.tr("Delete")
                      onTriggered: {
                          last_deleted_media = index
                          instagram.deleteMedia(id);
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
                      text: i18n.tr("Copy Share URL")
                      onTriggered: {
                          var share_url = "https://instagram.com/p/"+code;
                          Clipboard.push(share_url);
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
                                pageStack.pop();
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
                                pageStack.pop();
                            }
                        }
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

        sourceComponent: SuggestionsPanel {
            suggestionsModel: homeSuggestionsModel
            width: parent.width
        }
    }

    Loader {
        id: storiesFeedTrayLoader
        width: parent.width
        height: width/5 + units.gu(3)
        anchors {
            left: parent.left
            right: parent.right
        }
        visible: list_type === 'stories_feed'
        active: list_type === 'stories_feed'

        sourceComponent: StoriesTray {
            anchors {
                fill: parent
            }
        }
    }
}
