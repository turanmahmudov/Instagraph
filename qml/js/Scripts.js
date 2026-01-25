function linkClick(page, link, photoId) {
    var result = link.split("://");
    if(result[0] === "user") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: result[1]});
    } else if(result[0] === "userid") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: result[1]});
    } else if(result[0] === "tag") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/TagFeedPage.qml"), {tag: result[1]});
    } else if(result[0] === "likes") {
        pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: photoId});
    } else {
        Qt.openUrlExternally(link)
    }
}

function pushImageEdit(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/CameraEditPage.qml"))

    var r = {
        "x": 0,
        "y": 0,
        "width": 1,
        "height": 1
    }

    imageproc.loadImage("image://photo/" + String(url).replace('file://', '') + "?crop=true" + "&x="+ r.x + "&y=" + r.y +"&w=" + r.width + "&h=" + r.height);
}

function pushImageCaption(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/CameraCaptionPage.qml"), {imagePath: String(url).replace('file://', '')})
}

function pushImageCrop(page, url) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/CameraCropPage.qml"), {imagePath: String(url).replace('file://', '')})
}

function pushSingleImage(page, mediaId) {
    pageLayout.pushToCurrent(page, Qt.resolvedUrl("../ui/SinglePhoto.qml"), {photoId: mediaId})
}

function publishImage(url, caption, location, disableComments = false) {
    instagram.postImage(String(url).replace('file://', ''), caption, location, "", disableComments ? "1" : "0");
}

function openImportPhotoPage(currentpage, is_desktop = false) {
    if (is_desktop === true || is_desktop === "true" || parseInt(is_desktop) === 1) {
        pageLayout.pushToCurrent(currentpage, Qt.resolvedUrl("../ui/ImportPhotoPageDesktop.qml"))
    } else {
        pageLayout.pushToCurrent(currentpage, Qt.resolvedUrl("../ui/ImportPhotoPage.qml"))
    }
}

function logOut() {
    instagram.logout()

    Storage.deleteAccount(activeUsername)

    var allUsers = Storage.getAccounts()
    if (allUsers.length > 0) {
        activeUsername = allUsers[0].username
    } else {
        activeUsername = ""
    }

    pageLayout.removePages(homePage)
    mainView.init(true)
}

function logOutWithoutRemoving() {
    instagram.logout()

    activeUsername = ""

    pageLayout.removePages(homePage)
    mainView.init(true)
}

function switchAccount(username) {
    instagram.logout()

    activeUsername = username

    pageLayout.removePages(homePage)
    mainView.init(true)
}

function registered() {
    instagram.logout()

    pageLayout.removePages(homePage)
    init()
}
