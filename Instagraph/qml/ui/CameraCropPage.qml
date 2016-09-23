import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.1
import QtMultimedia 5.6

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: cameracroppage
    // Clear below codes

    property int editPhotoMode: 1

    property var imagePath

    header: PageHeader {
        title: i18n.tr("Crop")
        leadingActionBar.actions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: "back"
                onTriggered: {
                    pageStack.clear();
                    pageStack.push(tabs);
                }
            }
        ]
        trailingActionBar.actions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Next")
                iconName: "next"
                onTriggered: {
                    //Scripts.pushImageCaption(imagePath)

                    console.log(toCropImage.width)
                    console.log(toCropImage.height)
                    console.log(toCropFlickable.visibleArea.yPosition)

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
            Scripts.pushImageEdit(imagePath)
        }
    }
}
