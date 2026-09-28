import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtSystemInfo 5.0
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.Connectivity 1.0
import Lomiri.Layouts 1.0

import "js/Storage.js" as Storage
import "js/Helper.js" as Helper
import "js/Scripts.js" as Scripts

import "pages"
import "components"
import "components/Style"
import "components/Helpers"
import "viewmodels"
import "components/Constants"

import Instagram 1.0
import ImageProcessor 1.0
import InstagramMqtt 1.0

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "instagraph-devs.turan-mahmudov-l"

    backgroundColor: styleApp.mainView.backgroundColor

    anchorToKeyboard: true

    width: units.gu(50)
    height: units.gu(80)

    // Design
    Style {
        id: styleApp
    }
    StyleDark {
        id: styleDark
    }
    StyleLight {
        id: styleLight
    }

    // Constants (used directly as singletons - no need for aliases)
    // Access via: IconsConstants.more, PagesConstants.home, etc.

    // Settings
    Settings {
        id: settings

        property bool firstRun: true

        property string activeUsernameId: ""
        property string activeUsername: ""
        property string activeUserProfilePic: ""
    }

    // Variables
    property alias firstRun: settings.firstRun

    property string currentVersion: "0.1"

    property bool wideScreen: width > units.gu(50)

    property alias activeUsernameId: settings.activeUsernameId
    property alias activeUserId: settings.activeUsernameId  // Alias for consistency with instapyo
    property alias activeUsername: settings.activeUsername
    property alias activeUserProfilePic: settings.activeUserProfilePic

    property bool loggedIn: false
    property bool loginPageActive: false
    property string tmpUsername: ""
    property string tmpPassword: ""
    property var twoFactorData: null

    signal directMessageNotified(string igAction)
    signal locationSelected(var location)

    property alias appStore: appStore
    property var activeTransfer

    // API
    Instagram {
        id: instagram
    }

    // MQTT - FBNS push notifications
    InstagramMqtt {
        id: mqtt
    }

    // Image Filters
    ImageProcessor {
        id: imageproc

        // Default filter
        filterUrl: "qrc:///ImageProcessor/qml/filters/NoFilter.qml"
    }

    // URI Handler
    UriHandlerHelper {
        id: uriHandler
    }

    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    // Pages
    AdaptivePageLayout {
        id: pageLayout

        anchors.fill: parent

        layouts: [
            PageColumnsLayout {
                PageColumn {
                    fillWidth: true
                }
            }
        ]

        function pushToCurrent(source, page, properties) {
            pageLayout.addPageToCurrentColumn(source, page, properties);
        }

        function pushToNext(source, page, properties) {
            pageLayout.addPageToNextColumn(source, page, properties);
        }

        // Pages
        HomePage {
            id: homePage
        }
        ExploreFeedPage {
            id: exploreFeedPage
        }
        ActivityPage {
            id: activityPage
        }
        UserPage {
            id: userPage
        }
    }

    Component.onCompleted: {
        loading.visible = true;

        init();
    }

    function init(force) {
        tryToLogin(force);
    }

    function tryToLogin(force) {
        var username = activeUsername;
        var password = Storage.getAccount(username);

        if (username === "" || password === "" || username === undefined || password === undefined || username === null || password === null) {
            loginPageActive = true;
            goLogin();
        } else {
            sessionViewModel.login(force, username, password);
        }
    }

    function goLogin() {
        console.log('GO LOGIN PAGE');

        pageLayout.primaryPageSource = Qt.resolvedUrl("pages/LoginPage.qml");
    }

    LoadingSpinner {
        id: loading
    }

    // Network error popup component
    Component {
        id: networkErrorPopupComponent
        ErrorPopup {
            error_text: i18n.tr("Network Error")
            error_subtitle_text: i18n.tr("Your device must be connected to the internet.")
        }
    }

    SessionViewModel {
        id: sessionViewModel
        onProfileConnected: {
            if (loginPageActive && tmpUsername != "" && tmpPassword != "") {
                Storage.insertAccount(tmpUsername, tmpPassword);
                activeUsername = tmpUsername;
            }
            loggedIn = true;
            loginPageActive = false;
            anchorToKeyboard = true;
            loading.visible = false;

            activeUsernameId = usernameId;

            pageLayout.primaryPage = homePage;

            // Get Data
            // Home Timeline
            homePage.getHomeFeed();

            // Activity page
            activityPage.getRecentActivity();

            // User page
            userPage.getUsernameInfo();

            // Connect MQTT for push notifications
            sessionViewModel.connectPush(activeUsernameId);
        }
        onTwoFactorRequired: {
            // Store the 2FA data and load the 2FA page as primary
            twoFactorData = answer;
            pageLayout.primaryPageSource = Qt.resolvedUrl("pages/2FactorLoginPage.qml");

            loading.visible = false;
        }
    }

    // MQTT FBNS push notification handlers
    Connections {
        target: mqtt

        function onFbnsConnectionChanged(connected) {
            console.log("MQTT FBNS connected:", connected);
        }

        function onPushNotificationReceived(notification) {
            var ck = notification.collapseKey;
            console.log("MQTT push [" + ck + "]:", notification.message);

            switch (ck) {
            case "direct_v2_message":
                directMessageNotified(notification.igAction || "");
                break;
            case "like":
            case "like_on_tag":
            case "comment_like":
            case "comment":
            case "mentioned_comment":
            case "comment_on_tag":
            case "reply_to_comment_with_threading":
            case "new_follower":
            case "private_user_follow_request":
            case "follow_request_approved":
            case "usertag":
                activityPage.getRecentActivity();
                break;
            }
        }
    }
}
