import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3

import ".."
import "../Actions"
import "../Feed"
import "../Constants"
import "../../viewmodels"

import "../../js/Scripts.js" as Scripts
import "../../js/Helper.js" as Helper

Column {
    id: mediaentry
    spacing: units.gu(1)

    property bool showCarousel: false
    property bool enableVideoPlayback: false

    // Model data with default fallbacks to prevent undefined errors
    readonly property var userData: user || {
        username: "",
        pk: "",
        profile_pic_url: ""
    }
    readonly property var locationData: location || {
        name: ""
    }
    readonly property var captionData: caption || {
        text: "",
        user: {
            username: ""
        }
    }
    readonly property var carouselMediaData: carousel_media_obj || {
        media: []
    }
    readonly property var imageData: images_obj || {
        candidates: []
    }
    readonly property var previewCommentsData: preview_comments || {
        comments: []
    }
    readonly property bool canViewMoreComments: can_view_more_preview_comments || false
    readonly property int commentCount: comment_count || 0

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
                source: userData.profile_pic_url || "../../images/not_found_user.jpg"

                MouseArea {
                    anchors.fill: parent
                    onClicked: pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.user, {
                        usernameId: userData.pk
                    })
                }
            }
        }

        Column {
            spacing: units.gu(0.2)

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Label {
                text: userData.username || ''
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap

                MouseArea {
                    anchors.fill: parent
                    onClicked: pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.user, {
                        usernameId: userData.pk
                    })
                }
            }

            Label {
                text: locationData.name || ''
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

        property bool isCarousel: showCarousel && carouselMediaData.media && carouselMediaData.media.length > 0
        property var bestImage: calculateBestImage(isCarousel, media_type, carouselMediaData, imageData)

        width: parent.width
        height: calculateHeight(isCarousel, media_type)

        function calculateHeight(isCarousel, media_type) {
            if (isCarousel) {
                return (parent.width / bestImage.width * bestImage.height) + units.gu(2);
            }
            if (media_type === 1 || media_type === 2 || media_type === 8) {
                return parent.width / bestImage.width * bestImage.height;
            }
            return 0;
        }

        function calculateBestImage(isCarousel, media_type, carousel_media_obj, images_obj) {
            if (isCarousel) {
                return Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width);
            }
            if (media_type === 1 || media_type === 2 || media_type === 8) {
                // For carousel (media_type 8), show first image when not in carousel mode
                if (media_type === 8 && typeof carousel_media_obj.media !== 'undefined' && carousel_media_obj.media.length > 0) {
                    return Helper.getBestImage(carousel_media_obj.media[0].image_versions2.candidates, parent.width);
                }
                return Helper.getBestImage(images_obj.candidates, parent.width);
            }
            return {
                "width": 0,
                "height": 0,
                "url": ""
            };
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

            onLikeClicked: mediaActions.like()
            onUnlikeClicked: mediaActions.unlike()
        }

        OpenCommentsAction {
            id: openCommentsAction
            width: units.gu(4)
            height: width

            onOpenCommentsClicked: pageLayout.pushToNext(currentPage, PagesConstants.comments, {
                photoId: id,
                mediaUserId: user.pk
            })
        }

        OpenShareAction {
            id: openShareAction
            width: units.gu(4)
            height: width

            onOpenShareClicked: pageLayout.pushToCurrent(currentPage, PagesConstants.share_media, {
                mediaId: id,
                mediaUser: user
            })
        }

        Item {
            Layout.fillWidth: true
        }

        SaveAction {
            id: saveAction
            width: units.gu(4)
            height: width
            Layout.alignment: Qt.AlignRight

            onSaveClicked: mediaActions.save()
            onUnsaveClicked: mediaActions.unsave()
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
            onClicked: pageLayout.pushToNext(currentPage, PagesConstants.media_likers, {
                mediaId: id
            })
        }
    }

    Column {
        x: units.gu(1)
        width: parent.width - units.gu(2)
        spacing: units.gu(0.5)

        Text {
            visible: captionData.text && captionData.text.length > 0
            text: visible ? Helper.formatUser(captionData.user.username) + ' ' + Helper.formatString(captionData.text) : ""
            wrapMode: Text.WordWrap
            width: parent.width
            textFormat: Text.RichText
            color: styleApp.common.textColor
            onLinkActivated: Scripts.linkClick(currentPage, link)
        }

        Label {
            visible: canViewMoreComments
            text: i18n.tr("View all %1 comments").arg(commentCount)
            wrapMode: Text.WordWrap
            width: parent.width
            fontSize: "medium"
            color: styleApp.common.text2Color
            font.weight: Font.Normal

            MouseArea {
                anchors.fill: parent
                onClicked: pageLayout.pushToNext(currentPage, PagesConstants.comments, {
                    photoId: id,
                    mediaUserId: userData.pk
                })
            }
        }

        Repeater {
            enabled: previewCommentsData.comments && previewCommentsData.comments.length > 0
            model: enabled ? previewCommentsData.comments : []

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
            onDoubleClicked: mediaActions.like()
        }
    }

    Component {
        id: carouselMedia

        CarouselMedia {
            id: carouselItem
            onDoubleClicked: mediaActions.like()
        }
    }

    Component {
        id: popupComponent

        FeedActionsPopup {
            id: actionsPopup

            onOpenEditClicked: pageLayout.pushToCurrent(currentPage, PagesConstants.edit_media, {
                mediaId: id
            })
            onCopyLinkClicked: Clipboard.push(`https://instagram.com/p/${code}`)
            onDownloadClicked: mediaDownload.download(buildDownloadItems())
            onDeleteMediaClicked: mediaActions.deleteMedia()
            onEnableCommentsClicked: mediaActions.enableComments()
            onDisableCommentsClicked: mediaActions.disableComments()
            onRemoveTagClicked: mediaActions.removeSelfTag()
        }
    }

    DownloadMediaViewModel {
        id: mediaDownload
        onDownloaded: {
            if (Scripts.isDesktop()) {
                PopupUtils.open(Scripts.saveToDownloads(fileUrls) ? savedPopupComponent : saveFailedPopupComponent);
            } else {
                Scripts.openMediaExporter(currentPage, fileUrls, contentType);
            }
        }
        onDownloadFailed: PopupUtils.open(saveFailedPopupComponent)
    }

    function buildDownloadItems() {
        var entries = carouselMediaData.media && carouselMediaData.media.length > 0 ? carouselMediaData.media : [{
                "media_type": media_type,
                "image_versions2": imageData,
                "video_url": video_url
            }];

        var items = [];
        for (var i = 0; i < entries.length; i++) {
            var entry = entries[i];
            if (entry.media_type === 2) {
                items.push({
                    "url": entry.video_url || entry.video_versions[0].url,
                    "isVideo": true
                });
            } else {
                items.push({
                    "url": Helper.getLargestImage(entry.image_versions2.candidates).url,
                    "isVideo": false
                });
            }
        }
        return items;
    }

    MediaActionsViewModel {
        id: mediaActions
        mediaId: id
        onLikeUpdated: likeAction.is_liked = liked
        onSaveUpdated: saveAction.is_saved = saved
        onCommentsUpdated: currentModel.get(index).comments_disabled = disabled
        onSelfTagRemoved: currentModel.get(index).photo_of_you = false
        onDeleted: {
            currentModel.remove(index);
            if (currentModel.count === 0)
                pageLayout.removePages(currentPage);
        }
    }
}
