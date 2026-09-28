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
 * Used by SearchLocation and CameraCaptionPage.
 */
Item {
    id: viewModel
    visible: false

    property ListModel placesModel: ListModel {}

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

    WorkerScript {
        id: worker
        source: "../js/Workers/SearchWorker.js"
    }

    Connections {
        target: instagram
        function onSearchLocationDataReady(answer) {
            var data = JSON.parse(answer);
            worker.sendMessage({
                type: 'searchVenues',
                obj: data.venues || [],
                model: placesModel,
                clear_model: true
            });
        }
    }
}
