import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import ".."

Page {
    id: pageitem

    BouncingProgressBar {
        anchors.top: pageitem.header.bottom
        visible: (typeof pageitem.list_loading != 'undefined' && pageitem.list_loading)
        z: 100
    }
}
