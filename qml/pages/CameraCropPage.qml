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

// Plugin imports
import ImageEditor 1.0

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

    ImageEditor {
        id: imageEditor
    }

    header: PageHeaderItem {
        title: i18n.tr("Crop")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: IconsConstants.chevron_left
                onTriggered: {
                    pageLayout.removePages(cameracroppage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Next")
                iconName: IconsConstants.chevron_right
                onTriggered: {
                    //Scripts.pushImageCaption(imagePath)

                    if (toCropImage.width > toCropImage.height) {
                        imageEditor.scaleImage(String(imagePath).replace('file://', ''));
                    } else {
                        var path = String(imagePath).replace('file://', '');
                        imageEditor.cropImage(path, path, Math.round(toCropImage.sourceSize.height * toCropFlickable.visibleArea.yPosition), true);
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

    Connections {
        target: imageEditor
        function onCropped() {
            imageEditor.scaleImage(String(imagePath).replace('file://', ''));
        }
        function onScaled() {
            Scripts.pushImageEdit(cameracroppage, imagePath);
        }
    }
}
