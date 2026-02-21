import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3

import ".."
import "../Actions"
import "../Feed"
import "../Constants"

import "../../js/Storage.js" as Storage
import "../../js/Scripts.js" as Scripts
import "../../js/Helper.js" as Helper

Column {
    id: mediaentry
    spacing: units.gu(1)

    property var lastActionId: null
    property var lastDeletedId: null
    property bool showCarousel: false
    property bool enableVideoPlayback: false

    Item {
        width: parent.width
        height: units.gu(0.1)
    }

    RowLayout {
        x: units.gu(1)
        spacing: units.gu(1.5)
        width: parent.width - units.gu(2)
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
                source: typeof user != 'undefined' && typeof user.profile_pic_url != 'undefined' ? user.profile_pic_url : "../../images/not_found_user.jpg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.user, { usernameId: user.pk })
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
                    anchors.fill: parent
                    onClicked: pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.user, { usernameId: user.pk })
                }
            }

            Label {
                text: typeof location != 'undefined' && typeof location.name != 'undefined' ? location.name : ''
                fontSize: "medium"
                font.weight: Font.Light
                wrapMode: Text.WordWrap
            }
        }

        PopupAction {
            id: popupAction
            width: units.gu(3)
            height: width

            Layout.alignment: Qt.AlignRight

            onPopupClicked: PopupUtils.open(popupComponent, popupAction)
        }
    }

    Loader {
        asynchronous: true

        property bool isCarousel: showCarousel && typeof carousel_media_obj.media !== 'undefined' && carousel_media_obj.media.length > 0
        property var bestImage: calculateBestImage(isCarousel, media_type, carousel_media_obj, images_obj)

        width: parent.width
        height: calculateHeight(isCarousel, media_type)

        function calculateHeight(isCarousel, media_type) {
            if (isCarousel) {
                return (parent.width/bestImage.width*bestImage.height) + units.gu(2)
            }
            if (media_type === 1 || media_type === 2 || media_type === 8) {
                return parent.width/bestImage.width*bestImage.height
            }
            return 0
        }

        function calculateBestImage(isCarousel, media_type, carousel_media_obj, images_obj) {
            if (isCarousel) {
                return Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width)
            }
            if (media_type === 1 || media_type === 2 || media_type === 8) {
                // For carousel (media_type 8), show first image when not in carousel mode
                if (media_type === 8 && typeof carousel_media_obj.media !== 'undefined' && carousel_media_obj.media.length > 0) {
                    return Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width)
                }
                return Helper.getBestImage(images_obj.candidates, parent.width)
            }
            return {"width":0, "height":0, "url":""}
        }

        sourceComponent: isCarousel ? carouselMedia : singleMedia
    }

    RowLayout {
        x: units.gu(1)
        spacing: units.gu(2)
        width: parent.width - units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter

        LikeAction {
            id: likeAction
            width: units.gu(4)
            height: width

            onLikeClicked: mediaentry.like()
            onUnlikeClicked: mediaentry.unlike()
        }

        OpenCommentsAction {
            id: openCommentsAction
            width: units.gu(4)
            height: width

            onOpenCommentsClicked: pageLayout.pushToNext(currentPage, PagesConstants.comments, { photoId: id, mediaUserId: user.pk })
        }

        OpenShareAction {
            id: openShareAction
            width: units.gu(4)
            height: width

            onOpenShareClicked: pageLayout.pushToCurrent(currentPage, Qt.resolvedUrl("../../ui/ShareMediaPage.qml"), {mediaId: id, mediaUser: user})
        }

        Item {
            Layout.fillWidth: true
        }

        SaveAction {
            id: saveAction
            width: units.gu(4)
            height: width
            Layout.alignment: Qt.AlignRight

            onSaveClicked: mediaentry.save()
            onUnsaveClicked: mediaentry.unsave()
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
            onClicked: pageLayout.pushToNext(currentPage, Qt.resolvedUrl("../../ui/MediaLikersPage.qml"), { photoId: id })
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
            text: visible ? Helper.formatUser(caption.user.username) + ' ' + Helper.formatString(caption.text) : ""
            wrapMode: Text.WordWrap
            width: parent.width
            textFormat: Text.RichText
            color: styleApp.common.textColor
            onLinkActivated: Scripts.linkClick(currentPage, link)
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
                onClicked: pageLayout.pushToNext(currentPage, PagesConstants.comments, { photoId: id })
            }
        }

        Repeater {
            enabled: typeof preview_comments.comments != 'undefined' && preview_comments.comments.length > 0
            model: enabled ? preview_comments.comments : []

            Text {
                width: parent.width
                text: Helper.formatUser(modelData.user.username) + ' ' + Helper.formatString(modelData.ctext)
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: styleApp.common.textColor
                onLinkActivated: Scripts.linkClick(currentPage, link)
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

        SingleMedia {
            id: mediaItem
            onDoubleClicked: like()
        }
    }

    Component {
        id: carouselMedia

        CarouselMedia {
            id: carouselItem
            onDoubleClicked: like()
        }
    }

    Component {
        id: popupComponent

        FeedActionsPopup {
            id: actionsPopup

            onOpenEditClicked: pageLayout.pushToCurrent(currentPage, PagesConstants.edit_media, {mediaId: id})
            onCopyLinkClicked: Clipboard.push(`https://instagram.com/p/${code}`)
            onDownloadMediaClicked: {
                // TODO
                //var singleDownload = downloadComponent.createObject(mainView)
                //singleDownload.contentType = ContentType.Pictures
                //singleDownload.download(images_obj.candidates[0].url)
            }
            onDeleteMediaClicked: {
                lastDeletedId = id
                instagram.deleteMedia(id)
            }
            onEnableCommentsClicked: {
                lastActionId = id
                instagram.enableMediaComments(id)
            }
            onDisableCommentsClicked: {
                lastActionId = id
                instagram.disableMediaComments(id)
            }
            onRemoveTagClicked: {
                lastDeletedId = id
                instagram.removeSelftag(id)
            }
        }
    }

    Connections {
        target: instagram
        
        onMediaDeleted: {
            if (lastDeletedId === id) {
                var data = JSON.parse(answer)
                if (data.did_delete) {
                    currentModel.remove(index)
                    if (currentModel.count === 0) pageLayout.removePages(currentPage)
                }
                lastDeletedId = null
            }
        }
        
        onRemoveSelftagDone: {
            if (lastDeletedId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") currentModel.get(index).photo_of_you = false
                lastDeletedId = null
            }
        }
        
        onEnableMediaCommentsDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") currentModel.get(index).comments_disabled = false
                lastActionId = null
            }
        }
        
        onDisableMediaCommentsDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") currentModel.get(index).comments_disabled = true
                lastActionId = null
            }
        }

        onLikeDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") likeAction.is_liked = true
                lastActionId = null
            }
        }
        onUnLikeDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") likeAction.is_liked = false
                lastActionId = null
            }
        }
        onSaveMediaDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") saveAction.is_saved = true
                lastActionId = null
            }
        }
        onUnsaveMediaDataReady: {
            if (lastActionId === id) {
                var data = JSON.parse(answer)
                if (data.status === "ok") saveAction.is_saved = false
                lastActionId = null
            }
        }
    }

    function like() {
        lastActionId = id
        instagram.like(id)
    }
    function unlike() {
        lastActionId = id
        instagram.unLike(id)
    }
    function save() {
        lastActionId = id
        instagram.saveMedia(id)
    }
    function unsave() {
        lastActionId = id
        instagram.unsaveMedia(id)
    }
}
