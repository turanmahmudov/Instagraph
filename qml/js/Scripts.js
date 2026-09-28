function linkClick(page, link, photoId) {
    var result = link.split("://");
    if (result[0] === "user") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/OtherUserPage.qml"), { usernameString: result[1] });
    } else if (result[0] === "userid") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/OtherUserPage.qml"), { usernameId: result[1] });
    } else if (result[0] === "tag") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/TagFeedPage.qml"), { tag: result[1] });
    } else if (result[0] === "likes") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/MediaLikersPage.qml"), { mediaId: photoId });
    } else {
        Qt.openUrlExternally(link)
    }
}

function pushImageEdit(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/CameraEditPage.qml"))

    var r = {
        "x": 0,
        "y": 0,
        "width": 1,
        "height": 1
    }

    imageproc.loadImage("image://photo/" + String(url).replace('file://', '') + "?crop=true" + "&x=" + r.x + "&y=" + r.y + "&w=" + r.width + "&h=" + r.height);
}

function pushImageCaption(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/CameraCaptionPage.qml"), { imagePath: String(url).replace('file://', '') })
}

function pushImageCrop(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/CameraCropPage.qml"), { imagePath: String(url).replace('file://', '') })
}

function pushSingleImage(page, mediaId) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../pages/SinglePhoto.qml"), { photoId: mediaId })
}

function openImportPhotoPage(currentpage, is_desktop = false) {
    if (is_desktop === true || is_desktop === "true" || parseInt(is_desktop) === 1) {
        pageLayout.pushToCurrent(currentpage, Qt.resolvedUrl("../pages/ImportPhotoPageDesktop.qml"))
    } else {
        pageLayout.pushToCurrent(currentpage, Qt.resolvedUrl("../pages/ImportPhotoPage.qml"))
    }
}

function logOut() {
    if (loggedIn) {
        instagram.logout()
        pageLayout.removePages(homePage)
    }

    Storage.deleteAccount(activeUsername)

    var allUsers = Storage.getAccounts()
    if (allUsers.length > 0) {
        activeUsername = allUsers[0].username
    } else {
        activeUsername = ""
    }

    mainView.init(true)
}

function goToAddAccount() {
    if (loggedIn) {
        pageLayout.removePages(homePage)
    }

    loginPageActive = true
    mainView.goLogin()
}

function switchAccount(username) {
    if (username === activeUsername && loggedIn) {
        // Already logged into this account, just go back to home
        pageLayout.primaryPage = homePage
        return
    }

    if (loggedIn) {
        pageLayout.removePages(homePage)
    }

    activeUsername = username

    mainView.init(true)
}

