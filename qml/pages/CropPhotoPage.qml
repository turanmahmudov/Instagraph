// Qt imports
import QtQuick 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Scripts.js" as Scripts

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"

PageItem {
    id: cropphotopage

    property string imagePath

    // Instagram accepts photos from 4:5 (portrait) to 1.91:1 (landscape)
    readonly property real minRatio: 0.8
    readonly property real maxRatio: 1.91

    property bool squareFrame: true
    property real zoom: 1.0

    readonly property bool imageReady: photo.status === Image.Ready && photo.implicitHeight > 0
    readonly property real imageRatio: imageReady ? photo.implicitWidth / photo.implicitHeight : 1
    readonly property real frameRatio: squareFrame ? 1 : Math.max(minRatio, Math.min(maxRatio, imageRatio))

    header: PageHeaderItem {
        title: i18n.tr("Crop")
        trailingActions: [
            Action {
                text: i18n.tr("Next")
                iconName: IconsConstants.chevron_right
                enabled: imageReady
                onTriggered: Scripts.openPhotoEditor(cropphotopage, imagePath, cropRect())
            }
        ]
    }

    function cropRect() {
        return {
            "x": cropArea.contentX / cropArea.contentWidth,
            "y": cropArea.contentY / cropArea.contentHeight,
            "width": cropArea.width / cropArea.contentWidth,
            "height": cropArea.height / cropArea.contentHeight
        };
    }

    function centerContent() {
        cropArea.contentX = (cropArea.contentWidth - cropArea.width) / 2;
        cropArea.contentY = (cropArea.contentHeight - cropArea.height) / 2;
    }

    function setZoom(newZoom) {
        var centerX = (cropArea.contentX + cropArea.width / 2) / cropArea.contentWidth;
        var centerY = (cropArea.contentY + cropArea.height / 2) / cropArea.contentHeight;

        zoom = Math.max(1.0, Math.min(4.0, newZoom));

        cropArea.contentX = Math.max(0, Math.min(cropArea.contentWidth - cropArea.width, centerX * cropArea.contentWidth - cropArea.width / 2));
        cropArea.contentY = Math.max(0, Math.min(cropArea.contentHeight - cropArea.height, centerY * cropArea.contentHeight - cropArea.height / 2));
    }

    onFrameRatioChanged: {
        zoom = 1.0;
        Qt.callLater(centerContent);
    }

    Rectangle {
        id: stage
        anchors {
            top: cropphotopage.header.bottom
            left: parent.left
            right: parent.right
        }
        height: Math.min(width, parent.height - cropphotopage.header.height - units.gu(12))
        color: "#000000"

        Flickable {
            id: cropArea

            readonly property real fitWidth: frameRatio >= 1 ? stage.width : stage.height * frameRatio
            readonly property real fitHeight: frameRatio >= 1 ? Math.min(stage.height, stage.width / frameRatio) : stage.height

            anchors.centerIn: parent
            width: fitWidth
            height: fitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            // The photo covers the frame; zoom scales it further
            contentWidth: (imageRatio > frameRatio ? height * imageRatio : width) * zoom
            contentHeight: (imageRatio > frameRatio ? height : width / imageRatio) * zoom

            onContentWidthChanged: {
                if (!moving) {
                    contentX = Math.max(0, Math.min(contentWidth - width, contentX));
                }
            }

            Image {
                id: photo
                width: cropArea.contentWidth
                height: cropArea.contentHeight
                source: imagePath ? "file://" + imagePath : ""
                autoTransform: true
                asynchronous: true
                cache: false
                smooth: true
                sourceSize.width: 2048
                sourceSize.height: 2048
                fillMode: Image.Stretch
                onStatusChanged: {
                    if (status === Image.Ready) {
                        Qt.callLater(centerContent);
                    }
                }
            }

            PinchArea {
                width: Math.max(cropArea.contentWidth, cropArea.width)
                height: Math.max(cropArea.contentHeight, cropArea.height)

                property real startZoom: 1.0

                onPinchStarted: startZoom = zoom
                onPinchUpdated: setZoom(startZoom * pinch.scale)

                MouseArea {
                    anchors.fill: parent
                    onWheel: setZoom(zoom * (wheel.angleDelta.y > 0 ? 1.1 : 1 / 1.1))
                    onDoubleClicked: setZoom(zoom > 1.0 ? 1.0 : 2.0)
                }
            }
        }

        ActivityIndicator {
            anchors.centerIn: parent
            running: photo.status === Image.Loading
        }

        Label {
            anchors.centerIn: parent
            visible: photo.status === Image.Error
            text: i18n.tr("This photo cannot be opened.")
            color: "#ffffff"
        }
    }

    Sections {
        id: toolbar
        anchors {
            top: stage.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: units.gu(1)
        }
        selectedIndex: 0
        onSelectedIndexChanged: squareFrame = selectedIndex === 0
        actions: [
            Action {
                text: i18n.tr("Square")
            },
            Action {
                text: i18n.tr("Original")
            }
        ]
    }

    Label {
        anchors {
            top: toolbar.bottom
            topMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }
        text: i18n.tr("Drag to position, pinch to zoom")
        fontSize: "small"
        color: styleApp.common.text2Color
    }
}
