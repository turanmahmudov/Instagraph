import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import Lomiri.Content 1.1
import QtMultimedia 5.12

import "../components"
import "../filters"
import "../effects"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

import ImageProcessor 1.0

PageItem {
    id: cameraeditpage

    property int editPhotoMode: functionSelector.selectedIndex

    property string imageFilter: "normal"

    header: PageHeaderItem {
        title: i18n.tr("Edit")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: "\uea5a"
                onTriggered: {
                    pageLayout.removePages(cameraeditpage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Next")
                iconName: "\uea5c"
                onTriggered: {
                    if (!imageproc.saveToDisk(instagram.photos_path() + "/" + new Date().valueOf() + ".jpg", 100)) {
                        console.log("ERROR", "File not saved!")
                        return
                    }
                }
            }
        ]

        contents: AbstractButton {
            id: clarityButton
            anchors.centerIn: parent
            height: parent.height
            width: units.gu(6)

            onClicked: {
                imageproc.clarity = 0.5

                claritySettingsLoader.active = !claritySettingsLoader.active
            }

            Rectangle {
                color: LomiriColors.slate
                opacity: 0.1
                anchors.fill: parent
                visible: clarityButton.pressed
            }

            Label {
                text: "\u2B24"
                font.pixelSize: units.gu(1)
                visible: imageproc.clarity != 0.0
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: clarityIcon.top
                }
            }

            Icon {
                id: clarityIcon
                anchors.centerIn: parent
                width: units.gu(3); height: width
                name: "display-brightness-symbolic"
                color: theme.palette.normal.backgroundText
            }
        }
    }

    FiltersList {
        id: filtersList
    }

    EffectsList {
        id: effectList
    }

    Column {
        id: previewColumn
        width: parent.width
        anchors.top: cameraeditpage.header.bottom

        Item {
            width: parent.width
            height: width
            clip: true

            Rectangle {
                anchors.fill: parent
                color: "#ffffff"
            }

            Loader {
                id: previewLoader
                anchors {
                    fill: parent
                }
                asynchronous: true
                sourceComponent: ImageProcessorOutput {
                    anchors.fill: parent
                    imageProcessor: imageproc
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

        Loader {
            id: functionViewLoader
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: functionSelector.top
            }

            sourceComponent: editPhotoMode == 0 ? filtersView : otherActionsView
            asynchronous: true

            Component {
                id: filtersView
                FiltersView {
                    model: filtersList
                    imageHandler: imageproc
                }
            }

            Component {
                id: otherActionsView
                OtherActionsView {
                    model: effectList.model
                    imageHandler: imageproc
                }
            }
        }

        Loader {
            id: claritySettingsLoader
            anchors.fill: parent
            active: false
            onActiveChanged: {
                if (active) {
                    // Close any filter setting panel from filters or other actions.
                    functionViewLoader.active = false
                    functionViewLoader.active = true
                }
            }

            sourceComponent: ClaritySettingsPanel { proc: imageproc }
        }

        FunctionSelector {
            id: functionSelector
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            selectedIndex: 0
            model: [ i18n.tr("Filters"), i18n.tr("Tools") ]
        }
    }
}
