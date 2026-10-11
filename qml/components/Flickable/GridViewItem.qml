import QtQuick 2.12 as QtQuick
import Lomiri.Components 1.3
import "flickableUtils.js" as FlickableUtils

QtQuick.GridView {
    id: gridView

    signal endApproached

    function notifyEndApproach() {
        if (FlickableUtils.isNearEnd(gridView, false)) {
            endApproached();
        }
    }

    flickDeceleration: FlickableUtils.calculateFlickDeceleration(units.gridUnit)
    maximumFlickVelocity: FlickableUtils.calculateMaximumFlickVelocity(units.gridUnit)

    onContentYChanged: Qt.callLater(notifyEndApproach)
    onContentHeightChanged: Qt.callLater(notifyEndApproach)
}
