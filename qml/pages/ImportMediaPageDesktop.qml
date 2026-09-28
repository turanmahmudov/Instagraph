// Qt imports
import QtQuick 2.12
import QtQuick.Dialogs 1.2

// Lomiri imports
import Lomiri.Components 1.3
import Lomiri.Content 1.3

// Component imports
import "../components"
import "../components/Page"

PageItem {
    id: picker

    // ContentType.Pictures, ContentType.Videos or ContentType.All
    property int contentType: ContentType.All
    property var onPicked: null

    readonly property string photoPatterns: "*.jpg *.jpeg *.png *.webp *.JPG *.JPEG *.PNG"
    readonly property string videoPatterns: "*.mp4 *.mov *.m4v *.MP4 *.MOV *.M4V"

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
            title: i18n.tr("Choose a photo or video")
            folder: shortcuts.pictures
            selectMultiple: false
            nameFilters: {
                if (picker.contentType === ContentType.Pictures) {
                    return [i18n.tr("Photos (%1)").arg(picker.photoPatterns)];
                }
                if (picker.contentType === ContentType.Videos) {
                    return [i18n.tr("Videos (%1)").arg(picker.videoPatterns)];
                }
                return [i18n.tr("Photos and videos (%1 %2)").arg(picker.photoPatterns).arg(picker.videoPatterns)];
            }
            onAccepted: {
                var url = fileDialog.fileUrl;
                var handler = picker.onPicked;
                pageLayout.removePages(picker);
                if (handler) {
                    handler(url);
                }
            }
            onRejected: pageLayout.removePages(picker)
            visible: parent.visible
        }
    }
}
