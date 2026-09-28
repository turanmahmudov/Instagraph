// Qt imports
import QtQuick 2.12

// JavaScript imports
import "../js/Helper.js" as Helper

// Component imports
import "../components/Constants"
import "../components/Stories"
import "../viewmodels"

StoryViewerPage {
    id: userStoriesPage

    property var userId
    property var allUsers: []

    // Bind navigation context
    currentEntryId: userId
    storiesModel: viewModel.storiesModel
    allEntries: allUsers

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
        viewModel.loadUserReel(userId);
    }

    onRequestLoadEntry: {
        userId = entryId;
        viewModel.loadUserReel(userId);
    }

    onHeaderClicked: {
        if (viewModel.user) {
            pageLayout.pushToCurrent(userStoriesPage, PagesConstants.user, {
                usernameId: viewModel.user.pk
            });
        }
    }
}
