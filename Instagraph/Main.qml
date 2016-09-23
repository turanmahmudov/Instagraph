import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import Ubuntu.Content 1.3

import "qml/js/Storage.js" as Storage
import "qml/js/Helper.js" as Helper
import "qml/js/Scripts.js" as Scripts

import "qml/ui"
import "qml/components"

import Instagram 1.0
import ImageProcessor 1.0

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "instagraph-donate.turan-mahmudov-l"
    anchorToKeyboard: true
    automaticOrientation: false

    width: units.gu(50)
    height: units.gu(75)

    property bool new_notifs: false
    property bool logged_in: false

    property var my_usernameId

    property bool searchPageOpenFirstTime: true

    property var uri: undefined

    property string current_version: "Alpha Donate"

    property alias appStore: appStore
    property var activeTransfer

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

            }
        }
    ]

    Instagram {
        id: instagram
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

            console.log("file saved as", path);

            Scripts.pushImageCaption(path)
        }
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
        var password = Storage.get("password")
        if (username === "" ||  password === "" || username === undefined || password === undefined || username === null || password === null ) {
            pageStack.push(Qt.resolvedUrl("qml/ui/LoginPage.qml"));
        } else {
            instagram.setUsername(username);
            instagram.setPassword(password);
            instagram.login(true);
            pageStack.push(tabs);
        }
    }

    function processUri() {
        // no process
        if (typeof uri === "undefined") return;

        if (logged_in) {
            var commands = uri.split("://")[1].split("/");

            // no process
            if (commands[1] == "") return;

            if (commands[1] == "p") {
                // media
            } else if (commands[1] == "explore") {
                // no process
                if (commands[2] == "") return;
                if (commands[3] == "") return;

                if (commands[2] == "tags") {
                    pageStack.push(Qt.resolvedUrl("qml/ui/TagFeedPage.qml"), {tag: commands[3]});
                } else if (commands[2] == "locations") {
                    // location
                }
            } else {
                pageStack.push(Qt.resolvedUrl("qml/ui/OtherUserPage.qml"), {usernameString: commands[1]});
            }

            console.log(uri)
            // https://www.instagram.com/ - main
            // https://www.instagram.com/esmer_elizadeh/ - user
            // https://www.instagram.com/p/BJL8VdDj60C6qZ8ovtBVzsufLIyiMNcTKZ1SBU0/ - media
            // https://www.instagram.com/explore/tags/gallery/ - tag
            // https://www.instagram.com/explore/locations/239426709/ - location
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

    Connections{
        target: instagram
        onProfileConnected: {
            logged_in = true
            my_usernameId = instagram.getUsernameId()

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
            pageStack.push(Qt.resolvedUrl("qml/ui/LoginPage.qml"));
        }
    }
}

