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
import "qrc:///ImageProcessor/qml/filters"
import "qrc:///ImageProcessor/qml/effects"
import ImageProcessor 1.0

PageItem {
    id: editphotopage

    property int editPhotoMode: functionSelector.selectedIndex

    property bool isSaving: false

    Connections {
        target: imageproc
        function onImageSaved(path) {
            if (!isSaving) {
                return;
            }

            isSaving = false;
            imageproc.__output.setDefaultSize();
            Scripts.openPhotoPublisher(editphotopage, path);
        }
    }

    header: PageHeaderItem {
        title: i18n.tr("Edit")
        leadingActions: [
            Action {
                id: closePageAction
                text: i18n.tr("Back")
                iconName: IconsConstants.chevron_left
                onTriggered: {
                    pageLayout.removePages(editphotopage);
                }
            }
        ]
        trailingActions: [
            Action {
                id: nextPageAction
                text: i18n.tr("Next")
                iconName: IconsConstants.chevron_right
                enabled: !isSaving
                onTriggered: {
                    isSaving = imageproc.saveToDisk(instagram.photos_path() + "/" + new Date().valueOf() + ".jpg", 95);
                }
            }
        ]

        contents: AbstractButton {
            id: clarityButton
            anchors.centerIn: parent
            height: parent.height
            width: units.gu(6)

            onClicked: {
                imageproc.clarity = 0.5;

                claritySettingsLoader.active = !claritySettingsLoader.active;
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
                width: units.gu(3)
                height: width
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
        anchors.top: editphotopage.header.bottom

        Item {
            width: parent.width
            height: width
            clip: true

            Rectangle {
                anchors.fill: parent
                color: "#000000"
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

            ActivityIndicator {
                anchors.centerIn: parent
                running: isSaving
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
                    functionViewLoader.active = false;
                    functionViewLoader.active = true;
                }
            }

            sourceComponent: ClaritySettingsPanel {
                proc: imageproc
            }
        }

        FunctionSelector {
            id: functionSelector
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            selectedIndex: 0
            model: [i18n.tr("Filters"), i18n.tr("Tools")]
        }
    }
}
