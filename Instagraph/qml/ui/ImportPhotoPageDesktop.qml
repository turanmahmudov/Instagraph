import QtQuick 2.12
import Ubuntu.Components 1.3
import QtQuick.Dialogs 1.2

import "../components"

PageItem {
    id: picker

    header: PageHeaderItem {
        title: i18n.tr("Choose from")
    }

    Loader {
        anchors.fill: parent
        active: true
        visible: active
        sourceComponent: filePickerComponent
    }

    Component {
        id: filePickerComponent

        FileDialog {
            id: fileDialog
            title: "Please choose a file"
            folder: shortcuts.home
            selectMultiple: false
            onAccepted: {
                mainView.fileImported(fileDialog.fileUrl)
                pageLayout.removePages(picker);
            }
            onRejected: {
                pageLayout.removePages(picker);
            }
            visible: parent.visible
        }
    }
}
