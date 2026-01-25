import QtQuick 2.9
import QtSystemInfo 5.0
import Qt.labs.settings 1.0
import QtQuick.LocalStorage 2.0
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.3
import Lomiri.DownloadManager 1.2
import Lomiri.Connectivity 1.0
import Lomiri.Layouts 1.0
import QtQml.Models 2.2

import "qml/js/Storage.js" as Storage
import "qml/js/Helper.js" as Helper
import "qml/js/Scripts.js" as Scripts

import "qml/ui"
import "qml/components"

import Instagram 1.0
import ImageProcessor 1.0
import CacheImage 1.0

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "instagraph-devs.turan-mahmudov-l"
    anchorToKeyboard: true
    automaticOrientation: false

    width: units.gu(50)
    height: units.gu(75)
    backgroundColor: theme.name == 'Lomiri.Components.Themes.SuruDark' ? "#030303" : "#FFFFFF"

    // Settings
    Settings {
        id: settings

        property string activeUsername: ""
        property string activeUserProfilePic: ""
    }

    // Variables
    property alias activeUsername: settings.activeUsername
    property alias activeUserProfilePic: settings.activeUserProfilePic

    property bool new_notifs: false
    property bool logged_in: false

    property bool loginPageIsActive: false

    property bool searchPageOpenFirstTime: true

    property var uri: undefined

    property string current_version: "0.1"

    property alias appStore: appStore
    property var activeTransfer

    readonly property bool isLandscape: width > height
    readonly property bool isWideScreen: (width > units.gu(100)) && isLandscape
    readonly property bool isPhone: width <= units.gu(50)

    // Signals
    signal networkerroroccured()

    // Connectivity
    Connections {
        target: Connectivity
    }

    Connections {
        target: mainView
        onNetworkerroroccured: {

        }
    }

    // Actions
    actions: [
        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconName: "\ueb6d"
            onTriggered: {

            }
        },
        Action {
            id: newDirectMessageAction
            text: i18n.tr("New Message")
            iconName: "\ueb48"
            onTriggered: {
                pageLayout.push(Qt.resolvedUrl("qml/ui/NewDirectMessagePage.qml"))
            }
        },
        Action {
            id: backAction
            text: i18n.tr("Back")
            iconName: "\uea5a"
            onTriggered: {
                pageLayout.pop()
            }
        }
    ]


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

    CacheImage {
        id: cacheImage
    }

    Component.onCompleted: {
        start();
    }

    function start() {
        init();
    }

    function init() {
        var username = Storage.get("username");
        var password = Storage.get("password");
        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null ) {
            loginPageIsActive = true;
            pageLayout.replacePageSource(Qt.resolvedUrl("qml/ui/LoginPage.qml"));
        } else {
            instagram.setUsername(username);
            instagram.setPassword(password);

            instagram.login(false, username, password, true);

            cacheImage.clean();
            cacheImage.init();
        }
    }

    // Works: Home, Tags, Users
    // Doesn't work: Single Media, Location Feed
    function processUri() {
        // no process
        if (typeof uri === "undefined") return;

        if (logged_in) {
            var commands = uri.split("://")[1].split("/");

            // no process
            if (commands[1] == "") return;

            if (commands[1] == "p") {
                // media
                return;
            } else if (commands[1] == "explore") {
                // no process
                if (commands[2] == "") return;
                if (commands[3] == "") return;

                if (commands[2] == "tags") {
                    //pageStack.push(Qt.resolvedUrl("qml/ui/TagFeedPage.qml"), {tag: commands[3]});
                } else if (commands[2] == "locations") {
                    // location
                    return;
                }
            } else {
                //pageStack.push(Qt.resolvedUrl("qml/ui/OtherUserPage.qml"), {usernameString: commands[1]});
            }

            console.log(uri)
            // https://www.instagram.com/ - main = Home
            // https://www.instagram.com/esmer_elizadeh/ - user == Users
            // https://www.instagram.com/p/BJL8VdDj60C6qZ8ovtBVzsufLIyiMNcTKZ1SBU0/ - media == Single Media
            // https://www.instagram.com/explore/tags/gallery/ - tag == Tags
            // https://www.instagram.com/explore/locations/239426709/ - location == Location Feed
        }
    }

    AdaptivePageLayout {
        id: pageLayout
        anchors.fill: parent

        primaryPage: homePage

        layouts: [
            PageColumnsLayout {
                when: isWideScreen
                PageColumn {
                    minimumWidth: units.gu(50)
                    maximumWidth: units.gu(70)
                    preferredWidth: units.gu(60)
                }
                PageColumn {
                    fillWidth: true
                }
            }
        ]

        // Pages
        HomePage {
            id: homePage
        }
        SearchPage {
            id: searchPage
        }
        NotifsPage {
            id: notifsPage
        }
        UserPage {
            id: userPage
        }

        // Functions
        function replacePageSource(pageSource) {
            pageLayout.removePages(pageLayout.primaryPage)
            pageLayout.primaryPageSource = pageSource
        }

        function replacePage(pageId) {
            pageLayout.removePages(pageLayout.primaryPage)
            pageLayout.primaryPage = pageId
        }

        function pop() {
            pageLayout.removePages(pageLayout.primaryPage)
        }

        function push(pageSource, args) {
            pageLayout.addPageToNextColumn(pageLayout.primaryPage, pageSource, args)
        }
    }

    Connections {
        target: UriHandler
        onOpened: {
            // no url
            if (uris.length === 0 ) return;

            uri = uris[0];
            processUri();
        }
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

    Connections{
        target: instagram
        onProfileConnected: {
            logged_in = true
            activeUsername = instagram.getUsernameId()

            // Home feed
            homePage.getMedia();

            // Search page
            //searchPage.getPopular();

            // Activity page
            notifsPage.getRecentActivity();

            // User page
            userPage.getUsernameInfo();
            //userPage.getUsernameFeed();

            // Open requested url after login
            processUri();
        }
    }

    Connections{
        target: instagram
        onProfileConnectedFail: {
            if (!loginPageIsActive) {
                loginPageIsActive = true
                pageLayout.replacePageSource(Qt.resolvedUrl("qml/ui/LoginPage.qml"))
            }
        }
    }
}
