// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtMultimedia 5.12

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.1

// JavaScript imports
import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: cameracroppage

    property int editPhotoMode: 1

    property var imagePath

    header: PageHeaderItem {
        title: i18n.tr("Crop")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: IconsConstants.flash_on
                onTriggered: {
                    pageLayout.removePages(cameracroppage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Next")
                iconName: IconsConstants.flash_off
                onTriggered: {
                    //Scripts.pushImageCaption(imagePath)


                    if (toCropImage.width > toCropImage.height) {
                        instagram.scaleImg(String(imagePath).replace('file://', ''));
                    } else {
                        instagram.cropImg(String(imagePath).replace('file://', ''), toCropFlickable.visibleArea.yPosition);
                    }
                }
            }

        ]
    }

    Column {
        width: parent.width
        anchors.top: cameracroppage.header.bottom

        Item {
            width: parent.width
            height: width
            clip: true

            Flickable {
                id: toCropFlickable
                width: parent.width
                height: parent.width
                contentWidth: toCropImage.width
                contentHeight: toCropImage.height
                clip: true

                Image {
                    id: toCropImage
                    visible: source ? true : false
                    source: 'file://' + imagePath
                    width: source ? parent.width : 0
                    clip: true
                    smooth: true
                    cache: true
                    //fillMode: Image.PreserveAspectCrop
                    fillMode: Image.PreserveAspectFit //delete this

                }
            }
        }
    }

    Connections{
        target: instagram
        onImgCropped: {
            instagram.scaleImg(String(imagePath).replace('file://', ''));
        }
        onImgScaled: {
            Scripts.pushImageEdit(cameracroppage, imagePath)
        }
    }
}
