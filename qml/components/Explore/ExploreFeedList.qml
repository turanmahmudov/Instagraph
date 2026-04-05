import QtQuick 2.12
import ".."
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import "../Feed"

Flickable {
    id: explorefeedlist
    contentHeight: layout.height

    signal refreshRequested

    GridLayout {
        id: layout
        rowSpacing: units.gu(0.1)
        columnSpacing: units.gu(0.1)
        columns: 3

        Repeater {
            model: exploreFeedModel

            Loader {
                asynchronous: true
                Layout.preferredWidth: (explorefeedlist.width - units.gu(0.1)) * rowSpan / 3
                Layout.preferredHeight: Layout.preferredWidth
                Layout.rowSpan: rowSpan
                Layout.columnSpan: columnSpan
                Layout.row: row
                Layout.column: column
                sourceComponent: GridFeedItem {
                    currentPage: explorePage
                    currentModel: exploreFeedModel
                    width: parent.width
                    height: parent.height
                }
            }
        }
    }

    PullToRefresh {
        parent: explorefeedlist
        refreshing: list_loading && exploreFeedModel.count == 0
        onRefresh: refreshRequested()
    }
}
