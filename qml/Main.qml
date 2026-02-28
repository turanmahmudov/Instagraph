import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtSystemInfo 5.0
import Qt.labs.settings 1.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.DownloadManager 1.2
import Lomiri.Connectivity 1.0
import Lomiri.Layouts 1.0

import "js/Storage.js" as Storage
import "js/Helper.js" as Helper
import "js/Scripts.js" as Scripts

import "pages"
import "components"
import "components/Style"
import "components/Helpers"
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
    Style { id: styleApp }
    StyleDark { id: styleDark }
    StyleLight { id: styleLight }

    // Constants (used directly as singletons - no need for aliases)
    // Access via: IconsConstants.inbox, PagesConstants.home, etc.

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

    signal fileImported(var fileUrl)
    signal locationSelected(var location)

    property bool mqttConnected: false

    function connectMqtt() {
        if (mqttConnected) {
            console.log("MQTT: Already connected")
            return
        }

        var sessionId = instagram.getSessionId()
        var phoneId = instagram.getPhoneId()

        console.log("MQTT: Connecting manually...")
        console.log("MQTT: userId=" + activeUsernameId)
        console.log("MQTT: sessionId=" + (sessionId ? sessionId.substring(0, 10) + "..." : "EMPTY"))
        console.log("MQTT: phoneId=" + phoneId)

        if (!sessionId || sessionId === "") {
            console.log("MQTT: ERROR - No session cookie available, cannot connect Realtime")
            return
        }

        mqtt.connectToMqtt(
            activeUsernameId,
            sessionId,
            phoneId,
            "Instagram 367.0.0.27.101 Android (35/15.0; 640dpi; 1440x3088; samsung; SM-S938U; s25u; qcom; en_US; 658859659)",
            "367.0.0.27.101",
            "3brTvx0="
        )
        mqttConnected = true
    }

    property alias appStore: appStore
    property var activeTransfer

    // API
    Instagram {
        id: instagram
    }

    // MQTT - Real-time notifications and live activity
    InstagramMqtt {
        id: mqtt
    }

    // Image Filters
    ImageProcessor {
        id: imageproc

        // Default filter
        filterUrl: Qt.resolvedUrl("filters/NoFilter.qml")

        // TODO: Move to C++
        onFilterChanged: {
            //filter.width = __output.width
            //filter.height = __output.height
            filter.img = __output.__clarityFilter
            filter.parent = __output.__filterContainer
            filter.anchors.fill = parent
        }

        onImageSaved: {
            __output.setDefaultSize()
            Scripts.pushImageCaption(pageLayout.primaryPage, path)
        }
    }

    // URI Handler
    UriHandlerHelper {
        id: uriHandler
    }

    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    Component {
        id: downloadComponent
        SingleDownload {
            autoStart: false
            property var contentType
            onDownloadIdChanged: {
                PopupUtils.open(downloadDialog, mainView, {"contentType" : contentType, "downloadId" : downloadId})
            }

            onFinished: {
                destroy()
            }
        }
    }

    Component {
        id: downloadDialog
        ContentDownloadDialog { }
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
            pageLayout.addPageToCurrentColumn(source, page, properties)
        }

        function pushToNext(source, page, properties) {
            pageLayout.addPageToNextColumn(source, page, properties)
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
        loading.visible = true

        init()
    }

    function init(force) {
        tryToLogin(force)
    }

    function tryToLogin(force) {
        var username = activeUsername
        var password = Storage.getAccount(username)

        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null) {
            loginPageActive = true
            goLogin()
        } else {
            instagram.setUsername(username)
            instagram.setPassword(password)

            instagram.login(force === true ? true : false, username, password, true)
        }
    }

    function goLogin() {
        console.log('GO LOGIN PAGE')

        pageLayout.primaryPageSource = Qt.resolvedUrl("pages/LoginPage.qml")
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

    Connections{
        target: instagram
        onProfileConnected: {
            console.log('PROFILE CONNECTED')

            if (loginPageActive && tmpUsername != "" && tmpPassword != "") {
                Storage.insertAccount(tmpUsername, tmpPassword)
                activeUsername = tmpUsername
            }
            loggedIn = true
            loginPageActive = false
            anchorToKeyboard = true
            loading.visible = false

            activeUsernameId = instagram.getUsernameId()

            pageLayout.primaryPage = homePage

            // Get Data
            // Home Timeline
            homePage.getHomeFeed()

            // Activity page
            activityPage.getRecentActivity();

            // User page
            userPage.getUsernameInfo();

            // MQTT is connected manually via the debug button in BottomMenu
        }
        onProfileConnectedFail: {

        }
        onTwoFactorRequired: {
            console.log('2FACTOR REQUIRED')

            // Store the 2FA data and load the 2FA page as primary
            twoFactorData = answer
            pageLayout.primaryPageSource = Qt.resolvedUrl("pages/2FactorLoginPage.qml")

            loading.visible = false
        }
    }

    // MQTT signal handlers for real-time updates
    Connections {
        target: mqtt

        // FBNS token received — register with Instagram's push API
        onFbnsTokenReceived: {
            console.log("MQTT: FBNS token received, registering push...")
            instagram.registerPush(token)
        }

        // Any push notification (catch-all)
        onPushNotificationReceived: {
            console.log("MQTT: RAW PUSH NOTIFICATION:", JSON.stringify(notification))
        }

        // Push notification: new DM
        onDmNotification: {
            console.log("MQTT: New DM notification")
            // Refresh inbox if on DirectInboxPage
            if (typeof directInboxPage !== "undefined") {
                instagram.getInbox()
            }
        }

        // Push notification: someone liked your post
        onLikeNotification: {
            console.log("MQTT: Like notification")
            activityPage.getRecentActivity()
        }

        // Push notification: new comment
        onCommentNotification: {
            console.log("MQTT: Comment notification")
            activityPage.getRecentActivity()
        }

        // Push notification: new follower
        onFollowNotification: {
            console.log("MQTT: Follow notification")
            activityPage.getRecentActivity()
        }

        // Live: real-time direct message received (IRIS sync)
        onDirectMessageReceived: {
            console.log("MQTT: Live DM received - thread:", message.threadId)
            // Refresh inbox to show new message
            instagram.getInbox()
        }

        // Live: direct thread updated
        onDirectThreadUpdated: {
            console.log("MQTT: Thread updated:", threadUpdate.threadId)
        }

        // Live: typing indicator
        onTypingIndicatorReceived: {
            console.log("MQTT: Typing indicator")
        }

        // Connection state changes
        onFbnsConnectionChanged: {
            console.log("MQTT FBNS connected:", connected)
        }

        onRealtimeConnectionChanged: {
            console.log("MQTT Realtime connected:", connected)
        }
    }
}
