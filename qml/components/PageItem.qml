import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

Page {
    id: pageitem

    BouncingProgressBar {
        anchors.top: pageitem.header.bottom
        visible: instagram.busy || (typeof pageitem.list_loading != 'undefined' && pageitem.list_loading)
        z: 100
    }
}
