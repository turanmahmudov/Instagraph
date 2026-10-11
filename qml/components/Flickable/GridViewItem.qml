import QtQuick 2.12 as QtQuick
import Lomiri.Components 1.3
import "flickableUtils.js" as FlickableUtils

QtQuick.GridView {
    flickDeceleration: FlickableUtils.calculateFlickDeceleration(units.gridUnit)
    maximumFlickVelocity: FlickableUtils.calculateMaximumFlickVelocity(units.gridUnit)
}
