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
    id: takephotopage

    property int takePhotoMode: functionSelector.selectedIndex

    property var imagePath
    property bool awaitingImport: false
    property bool _hasBackCamera: false
    property bool _hasFrontCamera: false

    ImageEditor {
        id: imageEditor
    }

    // Detect available cameras at startup
    Component.onCompleted: {
        var cameras = QtMultimedia.availableCameras;
        for (var i = 0; i < cameras.length; i++) {
            if (cameras[i].position === Camera.BackFace) {
                _hasBackCamera = true;
            } else if (cameras[i].position === Camera.FrontFace) {
                _hasFrontCamera = true;
            }
        }

        // Default to back camera on phones, front camera on laptops/desktops
        if (_hasBackCamera) {
            camera.position = Camera.BackFace;
        } else if (_hasFrontCamera) {
            camera.position = Camera.FrontFace;
        }

        camera.start();
    }

    // Restart camera when page becomes visible again (after navigating back)
    onVisibleChanged: {
        if (visible) {
            camera.start();
        } else {
            camera.stop();
        }
    }

    header: PageHeaderItem {
        title: i18n.tr("Photo")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Close")
                iconName: IconsConstants.close
                onTriggered: {
                    pageLayout.removePages(takephotopage);
                }
            }
        ]
    }

    Column {
        id: previewColumn
        width: parent.width
        anchors.top: takephotopage.header.bottom

        Item {
            width: parent.width
            height: width
            clip: true

            Camera {
                id: camera

                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceAuto

                exposure {
                    exposureMode: Camera.ExposureAuto
                }
                flash.mode: Camera.FlashOff
                focus {
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointAuto
                }

                onCameraStatusChanged: {
                    if (cameraStatus === Camera.UnavailableStatus) {
                        console.warn("Camera: unavailable");
                    }
                }

                onError: {
                    console.warn("Camera error:", errorString);
                }

                imageCapture {
                    onImageCaptured: {
                        camera.stop();
                    }
                    onImageSaved: {
                        // Orientation
                        var rotation = 0;
                        if (camera.position == Camera.BackFace) {
                            rotation = camera.orientation % 360;
                        } else {
                            rotation = (360 - camera.orientation) % 360;
                        }

                        // Store captured image location to the variable
                        imagePath = path;

                        if (camera.orientation != 0) {
                            imageEditor.rotateImage(String(path).replace('file://', ''), rotation);
                        } else {
                            imageEditor.cropImage(String(path).replace('file://', ''), true);
                        }
                    }
                    onCaptureFailed: {
                        console.warn("Camera capture failed:", message);
                    }
                }
            }

            VideoOutput {
                source: camera
                fillMode: VideoOutput.PreserveAspectCrop
                anchors.fill: parent
                focus: visible
                autoOrientation: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (camera.focus.isFocusSupported) {
                        camera.focus.focusPointMode = Camera.FocusPointCustom;
                        camera.focus.customFocusPoint = Qt.point(mouseX / width, mouseY / height);
                    }
                }
            }

            Item {
                id: cameraTools
                width: parent.width
                height: units.gu(6)
                anchors {
                    bottom: parent.bottom
                }

                Row {
                    anchors {
                        centerIn: parent
                    }
                    spacing: (parent.width - units.gu(12))

                    CameraToolButton {
                        id: cameraTool_position
                        width: units.gu(5)
                        height: width
                        iconName: "camera-flip"
                        visible: _hasBackCamera && _hasFrontCamera
                        onClicked: {
                            if (camera.position == Camera.BackFace) {
                                camera.position = Camera.FrontFace;
                            } else if (camera.position == Camera.FrontFace) {
                                camera.position = Camera.BackFace;
                            }
                        }
                    }

                    CameraToolButton {
                        id: cameraTool_flash
                        width: units.gu(5)
                        height: width
                        iconName: camera.flash.mode == Camera.FlashOff ? "flash-off" : camera.flash.mode == Camera.FlashOn ? "flash-on" : "flash-auto"
                        onClicked: {
                            if (camera.flash.mode == Camera.FlashOff) {
                                camera.flash.mode = Camera.FlashAuto;
                            } else if (camera.flash.mode == Camera.FlashAuto) {
                                camera.flash.mode = Camera.FlashOn;
                            } else if (camera.flash.mode == Camera.FlashOn) {
                                camera.flash.mode = Camera.FlashOff;
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: toolsWorkContainer
        anchors {
            bottom: parent.bottom
            top: previewColumn.bottom
            left: parent.left
            right: parent.right
        }

        Item {
            id: cameraCaptureButtonItem
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: functionSelector.top
            }

            CameraCaptureButton {
                id: cameraCaptureButton
                width: units.gu(8)
                height: width
                anchors {
                    centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (camera.imageCapture.ready) {
                            camera.imageCapture.captureToLocation(instagram.photos_path() + '/');
                        }
                    }
                }
            }
        }

        FunctionSelector {
            id: functionSelector
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            selectedIndex: 1
            model: [i18n.tr("Library"), i18n.tr("Photo")]

            onSelectedIndexChanged: {
                if (selectedIndex == 0) {
                    awaitingImport = true;
                    Scripts.openImportPhotoPage(takephotopage, IS_DESKTOP);
                }
            }
        }
    }

    Connections {
        target: mainView
        enabled: awaitingImport
        function onFileImported(fileUrl) {
            awaitingImport = false;
            Scripts.pushImageCrop(takephotopage, fileUrl);
        }
    }

    Connections {
        target: imageEditor
        function onRotated() {
            imageEditor.cropImage(String(imagePath).replace('file://', ''), true);
        }
        function onCropped() {
            imageEditor.scaleImage(String(imagePath).replace('file://', ''));
        }
        function onScaled() {
            Scripts.pushImageEdit(takephotopage, imagePath);
        }
    }
}
