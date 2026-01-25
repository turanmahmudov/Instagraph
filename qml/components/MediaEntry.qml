import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import QtGraphicalEffects 1.0

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Column {
    id: entry_column
    spacing: units.gu(1)

    Item {
        width: parent.width
        height: units.gu(0.1)
    }

    RowLayout {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(1.5)
        anchors.horizontalCenter: parent.horizontalCenter

        Loader {
            width: units.gu(5)
            height: width
            asynchronous: true

            Layout.minimumWidth: units.gu(5)
            Layout.preferredWidth: units.gu(5)

            sourceComponent: CircleImage {
                width: parent.width
                height: width
                source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        pageLayout.pushToCurrent(pageLayout.primaryPage, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
                    }
                }
            }
        }

        Column {
            spacing: units.gu(0.2)

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Label {
                text: typeof user != 'undefined' && typeof user.username != 'undefined' ? user.username : ''
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        pageLayout.pushToCurrent(pageLayout.primaryPage, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
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

        Item {
            width: units.gu(3)
            height: width

            Layout.minimumWidth: units.gu(3)
            Layout.preferredWidth: units.gu(3)
            Layout.alignment: Qt.AlignVCenter

            LineIcon {
                id: openPopupButton
                anchors.verticalCenter: parent.verticalCenter
                name: "\ueb2e"
                color: styleApp.common.iconActiveColor
                iconSize: units.gu(2)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    PopupUtils.open(popoverComponent, openPopupButton)
                }
            }
        }
    }

    Loader {
        asynchronous: true

        property string mediaType: typeof carousel_media_obj.media !== 'undefined' && carousel_media_obj.media.length > 0 ? "carousel" : "single"

        property var bestImage: mediaType === "carousel" ?
                                    Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width) :
                                    media_type == 1 || media_type == 2 ?
                                        Helper.getBestImage(images_obj.candidates, parent.width) :
                                        {"width":0, "height":0, "url":""}


        width: parent.width
        height: mediaType === "carousel" ?
                    ((parent.width/bestImage.width*bestImage.height) + units.gu(2)) :
                    media_type == 1 || media_type == 2 ?
                        parent.width/bestImage.width*bestImage.height :
                        0

        sourceComponent: mediaType === "carousel" ? carouselMedia : singleMedia
    }

    RowLayout {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            width: units.gu(4)
            height: width

            Layout.minimumWidth: units.gu(4)
            Layout.preferredWidth: units.gu(4)

            LineIcon {
                id: imagelikeicon
                anchors.verticalCenter: parent.verticalCenter
                name: has_liked === true ? "\ueadf" : "\ueae1"
                color: has_liked === true ? LomiriColors.red : styleApp.common.iconActiveColor
                iconSize: units.gu(2.2)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (imagelikeicon.name == "\ueae1") {
                        last_like_id = id;
                        instagram.like(id);
                    } else if (imagelikeicon.name == "\ueadf") {
                        last_like_id = id;
                        instagram.unLike(id);
                    }
                }
            }
        }

        Item {
            width: units.gu(4)
            height: width

            Layout.minimumWidth: units.gu(4)
            Layout.preferredWidth: units.gu(4)

            LineIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "\uea74"
                color: typeof comments_disabled != 'undefined' && comments_disabled == true ? LomiriColors.lightGrey : styleApp.common.iconActiveColor
                iconSize: units.gu(2.2)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (typeof comments_disabled == 'undefined' || (typeof comments_disabled != 'undefined' && comments_disabled == false)) {
                        pageLayout.pushToNext(currentDelegatePage, Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id, mediaUserId: user.pk});
                    }
                }
            }
        }

        Item {
            width: units.gu(4)
            height: width

            Layout.minimumWidth: units.gu(4)
            Layout.preferredWidth: units.gu(4)

            LineIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: "\ueb80"
                iconSize: units.gu(2.2)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.pushToCurrent(currentDelegatePage, Qt.resolvedUrl("../ui/ShareMediaPage.qml"), {mediaId: id, mediaUser: user});
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Item {
            width: units.gu(4)
            height: width

            Layout.minimumWidth: units.gu(4)
            Layout.preferredWidth: units.gu(4)
            Layout.alignment: Qt.AlignRight

            Icon {
                id: imagesaveicon
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: units.gu(3)
                height: width
                color: styleApp.common.iconActiveColor
                source: typeof has_viewer_saved != 'undefined' && has_viewer_saved === true ? "../images/media_save.png" : "../images/media_save_bold.png"
                property var iname: typeof has_viewer_saved != 'undefined' && has_viewer_saved === true ? "save" : "unsave"
            }
            ColorOverlay {
                anchors.fill: imagesaveicon
                source: imagesaveicon
                color: styleApp.common.iconActiveColor
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (imagesaveicon.iname == "unsave") {
                        last_save_id = id;
                        instagram.saveMedia(id)
                    } else if (imagesaveicon.iname == "save") {
                        last_save_id = id;
                        instagram.unsaveMedia(id)
                    }
                }
            }

            Connections {
                target: instagram
                onSaveMediaDataReady: {
                    if (JSON.parse(answer).status === "ok" && last_save_id === id) {
                        imagesaveicon.source = "../images/media_save.png";
                        imagesaveicon.iname = "save"
                    }
                }
                onUnsaveMediaDataReady: {
                    if (JSON.parse(answer).status === "ok" && last_save_id === id) {
                        imagesaveicon.source = "../images/media_save_bold.png";
                        imagesaveicon.iname = "unsave"
                    }
                }
            }
        }
    }

    Label {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        visible: typeof like_count !== 'undefined' && like_count !== 0 ? true : false
        anchors.horizontalCenter: parent.horizontalCenter
        text: like_count + i18n.tr(" likes")
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap

        MouseArea {
            anchors.fill: parent
            onClicked: {
                pageLayout.pushToNext(currentDelegatePage, Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
            }
        }
    }

    Column {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(0.5)

        Text {
            visible: typeof caption !== 'undefined' && caption !== null ?
                         (typeof caption.text !== 'undefined' ? true : false) :
                         false
            text: typeof caption !== 'undefined' && caption !== null ?
                      (typeof caption.text !== 'undefined' ? Helper.formatUser(caption.user.username) + ' ' + Helper.formatString(caption.text) : "") :
                      ""
            wrapMode: Text.WordWrap
            width: parent.width
            textFormat: Text.RichText
            color: styleApp.common.textColor
            onLinkActivated: {
                Scripts.linkClick(currentDelegatePage, link)
            }
        }

        Label {
            visible: typeof has_more_comments != 'undefined' && has_more_comments === true ? true : false
            text: i18n.tr("View all %1 comments").arg(typeof comment_count != 'undefined' ? comment_count : 0)
            wrapMode: Text.WordWrap
            width: parent.width
            fontSize: "medium"
            color: styleApp.common.text2Color
            font.weight: Font.Normal

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageLayout.pushToNext(currentDelegatePage, Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id});
                }
            }
        }

        Repeater {
            enabled: typeof preview_comments.comments != 'undefined' && preview_comments.comments.length > 0
            model: typeof preview_comments.comments != 'undefined' && preview_comments.comments.length > 0 ? preview_comments.comments : []

            Text {
                width: parent.width
                text: Helper.formatUser(modelData.user.username) + ' ' + Helper.formatString(modelData.ctext)
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: styleApp.common.textColor
                onLinkActivated: {
                    Scripts.linkClick(currentDelegatePage, link)
                }
            }
        }

        Column {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: Helper.milisecondsToString(taken_at)
                fontSize: "small"
                color: styleApp.common.text2Color
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.capitalization: Font.AllLowercase
            }
        }
    }

    Component {
        id: singleMedia

        MediaItem {
            id: mediaItem
            Loader {
                id: videoLoader
                anchors.fill: parent
                asynchronous: true
                active: false
                visible: false

                sourceComponent: Item {
                    anchors.fill: parent
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

                    Component.onCompleted: {
                        console.log('PLAY VIDEO')
                        playPause()
                    }

                    function playPause() {
                        if (player.playbackState == MediaPlayer.PlayingState) {
                            player.stop()
                        } else {
                            player.play()
                        }
                    }
                }
            }

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    if (media_type === 2) {
                        videoLoader.active = true
                        videoLoader.visible = true

                        if (videoLoader.status == Loader.Ready) {
                            videoLoader.item.playPause()
                        }
                    }
                }
                onDoubleClicked: {
                    mediaItem.startLikeAnimation()

                    last_like_id = id;
                    instagram.like(id);
                }
            }
        }
    }

    Component {
        id: carouselMedia

        Item {
            CarouselSlider {
                id: carouselSlider
                width: parent.width
                height: parent.height - units.gu(2)
                dataArray: carousel_media_obj.media
            }

            Row {
                id: slideIndicator
                height: units.gu(2)
                spacing: units.gu(0.5)
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                }

                Repeater {
                    model: carousel_media_obj.media.length
                    delegate: Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: units.gu(1)
                        height: units.gu(1)
                        Rectangle {
                            property bool active: carouselSlider.currentIndex == index
                            height: active ? units.gu(0.9) : units.gu(0.7)
                            width: height
                            radius: width/2
                            anchors.verticalCenter: parent.verticalCenter
                            color: active ? LomiriColors.blue : styleApp.common.iconActiveColor
                            Behavior on color {
                                ColorAnimation {
                                    duration: LomiriAnimation.FastDuration
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: instagram
        onLikeDataReady: {
            if (JSON.parse(answer).status === "ok" && last_like_id === id) {
                imagelikeicon.color = LomiriColors.red;
                imagelikeicon.name = "\ueadf";
            }
        }
        onUnLikeDataReady: {
            if (JSON.parse(answer).status === "ok" && last_like_id === id) {
                imagelikeicon.color = styleApp.common.iconActiveColor;
                imagelikeicon.name = "\ueae1";
            }
        }
    }
}
