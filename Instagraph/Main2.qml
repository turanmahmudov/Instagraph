import QtQuick 2.12
import QtQuick.LocalStorage 2.12
import QtSystemInfo 5.0
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2
import Ubuntu.Connectivity 1.0
import Ubuntu.Layouts 1.0

import "qml/js/Storage.js" as Storage
import "qml/js/Helper.js" as Helper
import "qml/js/Scripts.js" as Scripts

import "qml/ui"
import "qml/components"
import "qml/components/Style"
import "qml/components/Helpers"

import Instagram 1.0
import ImageProcessor 1.0

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
    property alias activeUsername: settings.activeUsername
    property alias activeUserProfilePic: settings.activeUserProfilePic

    property bool loggedIn: false
    property bool loginPageActive: false
    property string tmpUsername: ""
    property string tmpPassword: ""

    // API
    Instagram {
        id: instagram
    }

    // Image Filters
    ImageProcessor {
        id: imageproc

        // Default filter
        filterUrl: Qt.resolvedUrl("qml/filters/NoFilter.qml")

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
            Scripts.pushImageCaption(path)
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
        SearchPage {
            id: searchPage
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

            instagram.login(force == true ? true : false, username, password, true)
        }
    }

    function goLogin() {
        console.log('GO LOGIN PAGE')

        pageLayout.primaryPageSource = Qt.resolvedUrl("qml/ui/LoginPage.qml")
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
            homePage.getTimelineFeed()

            // Activity page
            activityPage.getRecentActivity();

            // User page
            userPage.getUsernameInfo();
        }
        onProfileConnectedFail: {

        }
        onTwoFactorRequired: {
            console.log('2FACTOR REQUIRED')

            pageLayout.addPageToCurrentColumn(pageLayout.primaryPage, Qt.resolvedUrl("qml/ui/2FactorLoginPage.qml"), {answer: answer})

            loading.visible = false
        }
    }
}
