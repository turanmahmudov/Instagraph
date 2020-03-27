import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtMultimedia 5.6
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2
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

    Row {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(1)
        anchors {
            horizontalCenter: parent.horizontalCenter
        }

        CircleImage {
            id: feed_user_profile_image
            width: units.gu(5)
            height: width
            source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../images/not_found_user.jpg"

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
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
                        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: user.pk});
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
            id: openPopupButton
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
                    PopupUtils.open(popoverComponent, openPopupButton)
                }
            }
        }
    }

    Component {
        id: singleMedia

        Item {
            FeedImage {
                id: feed_image
                width: parent.width
                height:parent.width/bestImage.width*bestImage.height
                source: bestImage.url
            }

            Icon {
                id: animatingLikeIcon
                width: 0
                height: width
                anchors.centerIn: feed_image
                name: "like"
                color: theme.palette.normal.baseText
                opacity: 0

                NumberAnimation on width {
                    id: sizeAnimation
                    from: 0
                    to: units.gu(6)
                    duration: 750
                    easing.type: Easing.InOutQuad
                    running: false
                }

                NumberAnimation on opacity {
                    id: opacityAnimation
                    from: 0
                    to: 1
                    duration: 750
                    easing.type: Easing.InOutQuad
                    running: false

                        onRunningChanged: {
                        if (!running) {
                            destroyTimer.start()
                        }
                    }
                }

                Timer {
                    id: destroyTimer
                    interval: 500
                    running: false
                    repeat: false
                    onTriggered: {
                        animatingLikeIcon.opacity = 0
                    }
                }

                function sizeAnimation() {
                    sizeAnimation.start()
                }

                function opacityAnimation() {
                    opacityAnimation.start()
                }
            }

            Icon {
                id: is_video_icon
                width: units.gu(3)
                height: width
                anchors {
                    right: parent.right
                    rightMargin: units.gu(2)
                    top: parent.top
                    topMargin: units.gu(2)
                }
                visible: false
                name: "camcorder"
                color: theme.palette.normal.baseText
            }
            DropShadow {
                anchors.fill: is_video_icon
                source: is_video_icon
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8.0
                samples: 15
                color: theme.palette.normal.base
                visible: media_type === 2
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

            MouseArea {
                anchors {
                    fill: parent
                }
                onClicked: {
                    if (media_type === 2) {
                        console.log('PLAY VIDEO')
                        console.log(video_url)
                        if (player.playbackState == MediaPlayer.PlayingState) {
                            player.stop()
                        } else {
                            player.play()
                        }
                    }
                }
                onDoubleClicked: {
                    animatingLikeIcon.sizeAnimation()
                    animatingLikeIcon.opacityAnimation()

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
                model: carousel_media_obj
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
                    model: carousel_media_obj.count
                    delegate: Rectangle {
                        height: units.gu(0.7)
                        width: units.gu(0.7)
                        radius: width/2
                        antialiasing: true
                        anchors.verticalCenter: parent.verticalCenter
                        color: carouselSlider.currentIndex == index ? UbuntuColors.blue : theme.palette.normal.baseText
                        Behavior on color {
                            ColorAnimation {
                                duration: UbuntuAnimation.FastDuration
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
                imagelikeicon.color = UbuntuColors.red;
                imagelikeicon.name = "like";
            }
        }
        onUnLikeDataReady: {
            if (JSON.parse(answer).status === "ok" && last_like_id === id) {
                imagelikeicon.color = "";
                imagelikeicon.name = "unlike";
            }
        }
    }

    Loader {
        property var bestImage: typeof carousel_media_obj !== 'undefined' && carousel_media_obj.count > 0 ?
                                    Helper.getBestImage(carousel_media_obj.get(0).image_versions2.candidates, parent.width) :
                                    media_type == 1 || media_type == 2 ?
                                        Helper.getBestImage(images_obj.candidates, parent.width) :
                                        {"width":0, "height":0, "url":""}


        width: parent.width
        height: typeof carousel_media_obj !== 'undefined' && carousel_media_obj.count > 0 ?
                    ((parent.width/bestImage.width*bestImage.height) + units.gu(2)) :
                    media_type == 1 || media_type == 2 ?
                        parent.width/bestImage.width*bestImage.height :
                        0

        sourceComponent: typeof carousel_media_obj !== 'undefined' && carousel_media_obj.count > 0 ?
                             carouselMedia :
                             media_type == 1 || media_type == 2 ?
                                 singleMedia :
                                 singleMedia
    }

    Row {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            width: units.gu(4)
            height: width

            Icon {
                id: imagelikeicon
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                name: has_liked === true ? "like" : "unlike"
                color: has_liked === true ? UbuntuColors.red : theme.palette.normal.baseText
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
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                name: "message"
                color: typeof comments_disabled != 'undefined' && comments_disabled == true ? theme.palette.highlighted.baseText : theme.palette.normal.baseText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (typeof comments_disabled == 'undefined' || (typeof comments_disabled != 'undefined' && comments_disabled == false)) {
                        pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id, mediaUserId: user.pk});
                    }
                }
            }
        }

        Item {
            width: units.gu(4)
            height: width

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                width: units.gu(3)
                height: width
                name: "send"
                color: theme.palette.normal.baseText
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../ui/ShareMediaPage.qml"), {mediaId: id, mediaUser: user});
                }
            }
        }

        Item {
            width: parent.width - units.gu(24)
            height: units.gu(1)
        }

        Item {
            width: units.gu(4)
            height: width

            Icon {
                id: imagesaveicon
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: units.gu(3)
                height: width
                source: typeof has_viewer_saved != 'undefined' && has_viewer_saved === true ? "../images/media_save.png" : "../images/media_save_bold.png"
                property var iname: typeof has_viewer_saved != 'undefined' && has_viewer_saved === true ? "save" : "unsave"
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
                pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: id});
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
                (typeof caption.text !== 'undefined' ? Helper.formatUser(caption.user.username, theme.palette.normal.baseText) + ' ' + Helper.formatString(caption.text, theme.palette.normal.baseText) : "") :
                      ""
            wrapMode: Text.WordWrap
            width: parent.width
            color: theme.palette.normal.baseText
            textFormat: Text.RichText
            onLinkActivated: {
                Scripts.linkClick(link)
            }
        }

        Label {
            visible: typeof has_more_comments != 'undefined' && has_more_comments === true ? true : false
            text: i18n.tr("View all %1 comments").arg(typeof comment_count != 'undefined' ? comment_count : 0)
            wrapMode: Text.WordWrap
            width: parent.width
            fontSize: "medium"
            color: theme.palette.normal.baseText
            font.weight: Font.Normal

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../ui/CommentsPage.qml"), {photoId: id});
                }
            }
        }

        Repeater {
            enabled: typeof preview_comments != 'undefined'
            model: typeof preview_comments != 'undefined' ? preview_comments : []

            Text {
                width: parent.width
                text: Helper.formatUser(user.username, theme.palette.normal.baseText) + ' ' + Helper.formatString(ctext, theme.palette.normal.baseText)
                color: theme.palette.normal.baseText
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                onLinkActivated: {
                    Scripts.linkClick(link)
                }
            }
        }

        Column {
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: Helper.milisecondsToString(taken_at)
                fontSize: "small"
                color: theme.palette.normal.baseText
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.capitalization: Font.AllLowercase
            }
        }
    }
}
