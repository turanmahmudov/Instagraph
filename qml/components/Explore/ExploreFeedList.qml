import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import "../Feed"
import "../Flickable"

FlickableItem {
    id: explorefeedlist
    contentWidth: width
    contentHeight: layout.height

    property var currentPage: pageLayout.primaryPage
    readonly property real cellSize: (width - units.gu(0.1)) / 3
    readonly property real rowStep: cellSize + layout.rowSpacing
    readonly property int firstActiveRow: Math.floor((contentY - height) / rowStep)
    readonly property int lastActiveRow: Math.floor((contentY + 2 * height) / rowStep)
    property alias model: repeater.model
    property bool refreshing: false

    signal refreshRequested

    GridLayout {
        id: layout
        rowSpacing: units.gu(0.1)
        columnSpacing: units.gu(0.1)
        columns: 3

        Repeater {
            id: repeater

            Loader {
                asynchronous: true
                active: row + rowSpan > explorefeedlist.firstActiveRow && row <= explorefeedlist.lastActiveRow
                Layout.preferredWidth: (explorefeedlist.width - units.gu(0.1)) * columnSpan / 3
                Layout.preferredHeight: (explorefeedlist.width - units.gu(0.1)) * rowSpan / 3
                Layout.rowSpan: rowSpan
                Layout.columnSpan: columnSpan
                Layout.row: row
                Layout.column: column
                sourceComponent: GridFeedDelegate {
                    currentDelegatePage: explorefeedlist.currentPage
                    width: parent.width
                    height: parent.height
                }
            }
        }
    }

    PullToRefresh {
        parent: explorefeedlist
        refreshing: explorefeedlist.refreshing
        onRefresh: explorefeedlist.refreshRequested()
    }
}
