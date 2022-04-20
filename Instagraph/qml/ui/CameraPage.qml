import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.12
import Ubuntu.Content 1.1
import QtMultimedia 5.12

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: takephotopage

    property int takePhotoMode: functionSelector.selectedIndex

    property var imagePath

    header: PageHeaderItem {
        title: functionSelector.selectedIndex == 1 ? i18n.tr("Photo") : i18n.tr("Video")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Close")
                iconName: "\uea63"
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
                position: Camera.BackFace
                imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

                exposure {
                    exposureCompensation: -1.0
                    exposureMode: Camera.ExposurePortrait
                }
                flash.mode: Camera.FlashOff
                focus {
                    focusMode: Camera.FocusMacro
                    focusPointMode: Camera.FocusPointCenter
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
                        imagePath = path

                        if (camera.orientation != 0) {
                            instagram.rotateImg(String(path).replace('file://', ''), rotation);
                        } else {
                            instagram.squareImg(String(path).replace('file://', ''));
                        }
                    }
                }
            }

            VideoOutput {
                source: camera
                orientation: camera.orientation == 0 ? 0 : 270
                fillMode: VideoOutput.PreserveAspectCrop
                anchors.fill: parent
                focus : visible
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    camera.focus.focusPointMode = Camera.FocusPointCustom
                    camera.focus.customFocusPoint = Qt.point(mouseX, mouseY)

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
                    spacing: (parent.width-units.gu(12))

                    CameraToolButton {
                        id: cameraTool_position
                        width: units.gu(5)
                        height: width
                        iconName: "camera-flip"
                        onClicked: {
                            if (camera.position == Camera.BackFace) {
                                camera.position = Camera.FrontFace
                            } else if (camera.position == Camera.FrontFace) {
                                camera.position = Camera.BackFace
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
                                camera.flash.mode = Camera.FlashAuto
                            } else if (camera.flash.mode == Camera.FlashAuto) {
                                camera.flash.mode = Camera.FlashOn
                            } else if (camera.flash.mode == Camera.FlashOn) {
                                camera.flash.mode = Camera.FlashOff
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
                        // Capture Image to location
                        camera.imageCapture.captureToLocation(instagram.photos_path+'/')
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
            model: [ i18n.tr("Library"), i18n.tr("Photo"), i18n.tr("Video") ]

            onSelectedIndexChanged: {
                if (selectedIndex == 0) {
                    Scripts.openImportPhotoPage(takephotopage, IS_DESKTOP)

                    mainView.fileImported.connect(function(fileUrl) {
                        Scripts.pushImageCrop(takephotopage, fileUrl)
                    })
                }
            }
        }
    }

    Connections{
        target: instagram
        onImgRotated: {
            instagram.squareImg(String(imagePath).replace('file://', ''));
        }
        onImgSquared: {
            instagram.scaleImg(String(imagePath).replace('file://', ''));
        }
        onImgScaled: {
            Scripts.pushImageEdit(takephotopage, imagePath)
        }
    }
}
