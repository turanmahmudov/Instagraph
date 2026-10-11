import QtQuick 2.12 as QtQuick
import Lomiri.Components 1.3
import "flickableUtils.js" as FlickableUtils

QtQuick.ListView {
    id: listView

    signal endApproached

    function notifyEndApproach() {
        if (orientation === QtQuick.ListView.Vertical && FlickableUtils.isNearEnd(listView, verticalLayoutDirection === QtQuick.ListView.BottomToTop)) {
            endApproached();
        }
    }

    flickDeceleration: FlickableUtils.calculateFlickDeceleration(units.gridUnit)
    maximumFlickVelocity: FlickableUtils.calculateMaximumFlickVelocity(units.gridUnit)

    onContentYChanged: Qt.callLater(notifyEndApproach)
    onContentHeightChanged: Qt.callLater(notifyEndApproach)
}
