import QtQuick 2.12
import QtPositioning 5.2
import Instagram 1.0

/**
 * LocationSearchViewModel - ViewModel for location search
 *
 * Handles nearby location search logic:
 * - Device position tracking
 * - Location search around the current position
 *
 * Used by SearchLocation and PublishPage.
 */
Item {
    id: viewModel
    visible: false

    property JsonListModel placesModel: SearchResultModel {}

    property string query: ""

    readonly property var coordinate: positionSource.position.coordinate

    function search() {
        instagram.searchLocation(coordinate.latitude, coordinate.longitude, query);
    }

    PositionSource {
        id: positionSource
        updateInterval: 1000
        active: true
        onPositionChanged: viewModel.search()
    }

    Connections {
        target: instagram
        function onSearchLocationDataReady(answer) {
            placesModel.parseResponse(answer, ["venues"]);
            placesModel.appendParsed("venues", true, {
                "type": "searchVenues"
            });
        }
    }
}
