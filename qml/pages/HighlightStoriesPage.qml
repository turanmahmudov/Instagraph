// Qt imports
import QtQuick 2.12

// JavaScript imports
import "../js/Helper.js" as Helper

// Component imports
import "../components/Constants"
import "../components/Stories"
import "../viewmodels"

StoryViewerPage {
    id: highlightStoriesPage

    property var highlightId
    property var allHighlights: []

    // Bind navigation context
    currentEntryId: highlightId
    storiesModel: viewModel.storiesModel
    allEntries: allHighlights

    StoryReelViewModel {
        id: viewModel
        onReelLoaded: {
            headerImageSource = viewModel.coverUrl;
            headerTitle = viewModel.title;
            headerSubtitle = viewModel.unavailable ? "" : Helper.milisecondsToString(viewModel.firstTakenAt, true);
            storyUnavailable = viewModel.unavailable;
            getting = false;
        }
    }

    Component.onCompleted: {
        viewModel.loadHighlightReel(highlightId);
    }

    onRequestLoadEntry: {
        highlightId = entryId;
        viewModel.loadHighlightReel(highlightId);
    }

    onHeaderClicked: {
        if (viewModel.user) {
            pageLayout.pushToCurrent(highlightStoriesPage, PagesConstants.user, {
                usernameId: viewModel.user.pk
            });
        }
    }
}
