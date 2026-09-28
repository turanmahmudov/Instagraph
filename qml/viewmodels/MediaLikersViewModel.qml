import QtQuick 2.12
import Instagram 1.0

/**
 * MediaLikersViewModel - ViewModel for MediaLikersPage
 */
BaseUserListViewModel {
    id: viewModel
    hasPagination: false

    property var mediaId

    function load(nextId) {
        beginLoad(nextId);
        instagram.getMediaLikers(mediaId);
    }

    Connections {
        target: instagram
        function onMediaLikersDataReady(answer) {
            handleResponse(answer);
        }
    }
}
