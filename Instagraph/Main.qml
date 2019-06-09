import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Components.Popups 1.3
import Ubuntu.Content 1.3
import Ubuntu.DownloadManager 1.2

import "qml/js/Storage.js" as Storage
import "qml/js/Helper.js" as Helper
import "qml/js/Scripts.js" as Scripts

import "qml/ui"
import "qml/components"

import Instagram 1.0
import InstagramCheckPoint 1.0
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

    property bool new_notifs: false
    property bool logged_in: false

    property bool loginPageIsActive: false

    property var my_usernameId

    property bool searchPageOpenFirstTime: true

    property var uri: undefined

    property string current_version: "Alpha"

    property alias appStore: appStore
    property var activeTransfer

    readonly property bool isLandscape: width > height
    readonly property bool isWideScreen: (width > units.gu(120)) && isLandscape
    readonly property bool isPhone: width <= units.gu(50)

    // Main Actions
    actions: [
        Action {
            id: refreshAction
            text: i18n.tr("Refresh")
            iconName: "reload"
            onTriggered: {

            }
        },
        Action {
            id: inboxAction
            text: i18n.tr("Inbox")
            iconName: "inbox"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("qml/ui/DirectInboxPage.qml"))
            }
        },
        Action {
            id: addPeopleAction
            text: i18n.tr("Discover People")
            iconName: "contact-new"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("qml/ui/DiscoverPeoplePage.qml"))
            }
        },
        Action {
            id: newDirectMessageAction
            text: i18n.tr("New Message")
            iconName: "add"
            onTriggered: {
                pageStack.push(Qt.resolvedUrl("qml/ui/NewDirectMessagePage.qml"))
            }
        }
    ]

    Instagram {
        id: instagram
    }

    InstagramCheckPoint {
        id: instagramCheckPoint
    }

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
        pageStack.clear();
        init();
    }

    function init() {
        var username = Storage.get("username");
        var password = Storage.get("password");
        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null ) {
            loginPageIsActive = true;
            pageStack.push(Qt.resolvedUrl("qml/ui/LoginPage.qml"));
        } else {
            instagram.setUsername(username);
            instagram.setPassword(password);

            instagram.login(false, username, password, true);

            cacheImage.clean();
            cacheImage.init();

            // Donate me dialog
            var donateMeShowed = Storage.get("donateMe");
            if (donateMeShowed === "" || typeof donateMeShowed == 'undefined') {
                PopupUtils.open(donateMeComponent);
                Storage.set("donateMe", "showed");
            }
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
                    pageStack.push(Qt.resolvedUrl("qml/ui/TagFeedPage.qml"), {tag: commands[3]});
                } else if (commands[2] == "locations") {
                    // location
                    return;
                }
            } else {
                pageStack.push(Qt.resolvedUrl("qml/ui/OtherUserPage.qml"), {usernameString: commands[1]});
            }

            console.log(uri)
            // https://www.instagram.com/ - main = Home
            // https://www.instagram.com/esmer_elizadeh/ - user == Users
            // https://www.instagram.com/p/BJL8VdDj60C6qZ8ovtBVzsufLIyiMNcTKZ1SBU0/ - media == Single Media
            // https://www.instagram.com/explore/tags/gallery/ - tag == Tags
            // https://www.instagram.com/explore/locations/239426709/ - location == Location Feed
        }
    }

    PageStack {
        id: pageStack
    }

    Tabs {
        id: tabs
        visible: false

        Tab {
            id: homeTab

            HomePage {
                id: homePage
            }
        }

        Tab {
            id: searchTab

            SearchPage {
                id: searchPage
            }
        }

        Tab {
            id: notifsTab

            NotifsPage {
                id: notifsPage
            }
        }

        Tab {
            id: userTab

            UserPage {
                id: userPage
            }
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

    Component {
        id: donateMeComponent

        Dialog {
            id: donateMeDialog
            title: i18n.tr("Donate me")
            text: i18n.tr("Donate to support me continue developing for Ubuntu.")

            Row {
                spacing: units.gu(1)
                Button {
                    width: parent.width/2 - units.gu(0.5)
                    text: i18n.tr("Ignore")
                    onClicked: PopupUtils.close(donateMeDialog)
                }

                Button {
                    width: parent.width/2 - units.gu(0.5)
                    text: i18n.tr("Donate")
                    color: UbuntuColors.blue
                    onClicked: {
                        Qt.openUrlExternally("https://liberapay.com/turanmahmudov")
                        PopupUtils.close(donateMeDialog)
                    }
                }
            }
        }
    }

    Connections{
        target: instagram
        onProfileConnected: {
            pageStack.push(tabs);

            logged_in = true
            my_usernameId = instagram.getUsernameId()

            // Home feed
            homePage.getMedia();

            // Search page
            searchPage.getPopular();

            // Activity page
            notifsPage.getRecentActivity();

            // User page
            userPage.getUsernameInfo();
            userPage.getUsernameFeed();

            // Open requested url after login
            processUri();
        }
    }

    Connections{
        target: instagram
        onProfileConnectedFail: {
            if (!loginPageIsActive) {
                loginPageIsActive = true
                pageStack.clear()
                pageStack.push(Qt.resolvedUrl("qml/ui/LoginPage.qml"))
            }
        }
    }
}

