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
    divider.visible: false
    height: entry_column.height + units.gu(4)

    property var last_deleted_media
    property var thismodel
    property var thiscommentsmodel

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

    Column {
        id: entry_column
        spacing: units.gu(1)
        width: parent.width

        Item {
            width: parent.width
            height: units.gu(0.1)
        }

        Row {
            spacing: units.gu(1)
            width: parent.width
            anchors {
                horizontalCenter: parent.horizontalCenter
            }

            Item {
                width: units.gu(5)
                height: width

                UbuntuShape {
                    width: parent.width
                    height: width
                    radius: "large"

                    source: Image {
                        id: feed_user_profile_image
                        anchors {
                            centerIn: parent
                        }
                        width: parent.width
                        height: width
                        source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(width,height)
                        asynchronous: true
                        cache: true
                    }
                }

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                    }
                }
            }

            Column {
                spacing: units.gu(0.2)
                width: parent.width - units.gu(9)
                anchors {
                    verticalCenter: parent.verticalCenter
                }

                Label {
                    text: typeof user != 'undefined' && typeof user.username != 'undefined' ? user.username : ''
                    font.weight: Font.DemiBold
                    wrapMode: Text.WordWrap

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: user.username});
                        }
                    }
                }

                Label {
                    text: typeof location != 'undefined' && typeof location.name != 'undefined' ? location.name : ''
                    fontSize: "medium"
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                }
            }

            Icon {
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                width: units.gu(2)
                height: width
                name: "down"
                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (my_usernameId == user.pk || photo_of_you || (!user.is_private && code)) {
                            PopupUtils.open(popoverComponent)
                        }
                    }
                }
            }
        }

        Item {
            property var bestImage: Helper.getBestImage(image_versions2.candidates, parent.width)

            width: parent.width
            height: parent.width/bestImage.width*bestImage.height

            Image {
                id: feed_image
                width: parent.width
                height:parent.width/parent.bestImage.width*parent.bestImage.height
                fillMode: Image.PreserveAspectCrop
                source: parent.bestImage.url
                sourceSize: Qt.size(width,height)
                asynchronous: true
                cache: true // maybe false
                smooth: false
            }

            MediaPlayer {
                id: player
                source: video_url
                autoLoad: false
                autoPlay: false
                loops: MediaPlayer.Infinite
            }
            VideoOutput {
                id: videoOutput
                source: player
                fillMode: VideoOutput.PreserveAspectCrop
                width: 800
                height: 600
                anchors.fill: parent
                visible: media_type == 2
            }

            Icon {
                visible: media_type == 2
                width: units.gu(3)
                height: width
                name: "camcorder"
                color: "#ffffff"
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    top: parent.top
                    topMargin: units.gu(2)
                }
            }

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    /*if (media_type == 2) {
                        var singleDownload = downloadComponent.createObject(mainView)
                        singleDownload.contentType = ContentType.Videos
                        singleDownload.download(video_url)
                    }*/

                    if (media_type == 2) {
                        console.log(video_url)
                        if (player.playbackState == MediaPlayer.PlayingState) {
                            player.stop()
                        } else {
                            player.play()
                        }
                    }
                }
                onDoubleClicked: {
                    last_like_id = id;
                    instagram.like(id);
                }
            }

            Connections {
                target: instagram
                onLikeDataReady: {
                    if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                        imagelikeicon.color = UbuntuColors.red;
                        imagelikeicon.name = "like";
                    }
                }
                onUnLikeDataReady: {
                    if (JSON.parse(answer).status == "ok" && last_like_id == id) {
                        imagelikeicon.color = "";
                        imagelikeicon.name = "unlike";
                    }
                }
            }
        }

        Row {
            spacing: units.gu(2.3)
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: units.gu(4)
                height: width

                Icon {
                    id: imagelikeicon
                    anchors.centerIn: parent
                    width: units.gu(3)
                    height: width
                    name: has_liked == true ? "like" : "unlike"
                    color: has_liked == true ? UbuntuColors.red : "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (imagelikeicon.name == "unlike") {
                            last_like_id = id;
                            instagram.like(id);
                        } else if (imagelikeicon.name == "like") {
                            last_like_id = id;
                            instagram.unLike(id);
                        }
                    }
                }
            }

            Item {
                width: units.gu(4)
                height: width

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3)
                    height: width
                    name: "message"
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id, mediaUserId: user.pk});
                    }
                }
            }

            Item {
                width: units.gu(4)
                height: width

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3)
                    height: width
                    name: "share"
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/ShareMediaPage.qml"), {mediaId: id, mediaUser: user});
                    }
                }
            }

            Item {
                width: units.gu(4)
                height: width

                Icon {
                    anchors.centerIn: parent
                    width: units.gu(3)
                    height: width
                    name: "save"
                    color: "#000000"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var singleDownload = downloadComponent.createObject(mainView)
                        singleDownload.contentType = ContentType.Pictures
                        singleDownload.download(image_versions2.candidates[0].url)
                    }
                }
            }
        }

        Row {
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                width: parent.width
                height: units.gu(0.17)
                color: Qt.lighter(UbuntuColors.lightGrey, 1.2)
            }
        }

        Flow {
            visible: typeof like_count != 'undefined' && like_count != 0 ? true : false
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: units.gu(1)

            Icon {
                width: units.gu(2)
                height: width
                name: "like"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
                    }
                }
            }

            Label {
                text: like_count + i18n.tr(" likes")
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
                    }
                }
            }
        }

        Column {
            spacing: units.gu(0.5)
            width: parent.width - units.gu(3)

            Text {
                visible: typeof caption != 'undefined' && caption.text ? true : false
                text: typeof caption != 'undefined' && caption.text ? Helper.formatUser(caption.user.username) + ' ' + Helper.formatString(caption.text) : ""
                wrapMode: Text.WordWrap
                width: parent.width
                textFormat: Text.RichText
                onLinkActivated: {
                    Scripts.linkClick(link)
                }
            }

            Label {
                visible: has_more_comments == true ? true : false
                text: i18n.tr("View all %1 comments").arg(comment_count)
                color: UbuntuColors.darkGrey
                wrapMode: Text.WordWrap
                width: parent.width

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id});
                    }
                }
            }

            Repeater {
                model: thiscommentsmodel

                Text {
                    visible: c_image_id == pk && typeof comment != 'undefined' && comment.text ? true : false
                    text: c_image_id == pk && typeof comment != 'undefined' && comment.text ? Helper.formatUser(comment.user.username) + ' ' + Helper.formatString(comment.text) : ""
                    wrapMode: Text.WordWrap
                    width: entry_column.width
                    textFormat: Text.RichText
                    onLinkActivated: {
                        Scripts.linkClick(link)
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: Helper.milisecondsToString(taken_at)
                fontSize: "small"
                color: UbuntuColors.darkGrey
                font.weight: Font.Light
                wrapMode: Text.WordWrap
            }
        }
    }
}
