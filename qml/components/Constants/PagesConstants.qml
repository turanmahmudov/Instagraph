import QtQuick 2.12

pragma Singleton

QtObject {
    // Central page path constants to replace hardcoded Qt.resolvedUrl() calls
    // All paths are relative to the ui/ directory
    
    // Authentication
    readonly property string login: getQtResolvedUrl("LoginPage.qml")
    readonly property string register: getQtResolvedUrl("RegisterPage.qml")
    readonly property string two_fa: getQtResolvedUrl("2FactorLoginPage.qml")
    readonly property string checkpoint_info: getQtResolvedUrl("CheckpointInfo.qml")
    
    // Main Pages
    readonly property string home: getQtResolvedUrl("HomePage.qml")
    readonly property string explore: getQtResolvedUrl("ExploreFeedPage.qml")
    readonly property string activity: getQtResolvedUrl("ActivityPage.qml")
    
    // User Profile
    readonly property string current_user: getQtResolvedUrl("UserPage.qml")
    readonly property string user: getQtResolvedUrl("OtherUserPage.qml")
    readonly property string edit_profile: getQtResolvedUrl("EditProfilePage.qml")
    readonly property string change_password: getQtResolvedUrl("ChangePasswordPage.qml")
    readonly property string user_followers: getQtResolvedUrl("UserFollowers.qml")
    readonly property string user_followings: getQtResolvedUrl("UserFollowings.qml")
    
    // Media
    readonly property string photo: getQtResolvedUrl("SinglePhoto.qml")
    readonly property string comments: getQtResolvedUrl("CommentsPage.qml")
    readonly property string media_likers: getQtResolvedUrl("MediaLikersPage.qml")
    readonly property string liked_media: getQtResolvedUrl("LikedMediaPage.qml")
    readonly property string saved_media: getQtResolvedUrl("SavedMediaPage.qml")
    readonly property string edit_media: getQtResolvedUrl("EditMediaPage.qml")
    readonly property string share_media: getQtResolvedUrl("ShareMediaPage.qml")
    
    // Camera
    readonly property string camera: getQtResolvedUrl("CameraPage.qml")
    readonly property string camera_crop: getQtResolvedUrl("CameraCropPage.qml")
    readonly property string camera_edit: getQtResolvedUrl("CameraEditPage.qml")
    readonly property string camera_caption: getQtResolvedUrl("CameraCaptionPage.qml")
    readonly property string import_photo: getQtResolvedUrl("ImportPhotoPage.qml")
    readonly property string import_photo_desktop: getQtResolvedUrl("ImportPhotoPageDesktop.qml")
    
    // Direct Messages
    readonly property string direct_inbox: getQtResolvedUrl("DirectInboxPage.qml")
    readonly property string direct_thread: getQtResolvedUrl("DirectThreadPage.qml")
    readonly property string new_direct_message: getQtResolvedUrl("NewDirectMessagePage.qml")
    
    // Stories
    readonly property string user_stories: getQtResolvedUrl("UserStoriesPage.qml")
    readonly property string highlight_stories: getQtResolvedUrl("HighlightStoriesPage.qml")
    
    // Discovery
    readonly property string tag_feed: getQtResolvedUrl("TagFeedPage.qml")
    readonly property string location_feed: getQtResolvedUrl("LocationFeedPage.qml")
    readonly property string search_location: getQtResolvedUrl("SearchLocation.qml")
    readonly property string suggestions: getQtResolvedUrl("SuggestionsPage.qml")
    readonly property string follow_requests: getQtResolvedUrl("FollowRequestsPage.qml")
    
    // Settings
    readonly property string options: getQtResolvedUrl("OptionsPage.qml")
    readonly property string blocked_users: getQtResolvedUrl("BlockedUsers.qml")
    readonly property string about: getQtResolvedUrl("About.qml")
    readonly property string credits: getQtResolvedUrl("Credits.qml")
    
    function getQtResolvedUrl(page) {
        return Qt.resolvedUrl(`../../ui/${page}`)
    }
}
