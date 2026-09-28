function linkClick(page, link, photoId) {
    var result = link.split("://");
    if (result[0] === "user") {
        pageLayout.pushToCurrent(page, PagesConstants.user, { usernameString: result[1] });
    } else if (result[0] === "userid") {
        pageLayout.pushToCurrent(page, PagesConstants.user, { usernameId: result[1] });
    } else if (result[0] === "tag") {
        pageLayout.pushToCurrent(page, PagesConstants.tag_feed, { tag: result[1] });
    } else if (result[0] === "likes") {
        pageLayout.pushToCurrent(page, PagesConstants.media_likers, { mediaId: photoId });
    } else {
        Qt.openUrlExternally(link)
    }
}

function localPath(url) {
    return decodeURIComponent(String(url).replace('file://', ''))
}

function isVideoFile(url) {
    return /\.(mp4|mov|m4v|3gp|webm)$/i.test(String(url))
}

// contentType is a Lomiri.Content ContentType value
function openMediaPicker(page, contentType, onPicked) {
    var desktop = IS_DESKTOP === true || IS_DESKTOP === "true" || parseInt(IS_DESKTOP) === 1
    var picker = desktop ? PagesConstants.import_media_desktop : PagesConstants.import_media
    pageLayout.pushToCurrent(page, picker, { contentType: contentType, onPicked: onPicked })
}

function openPostEditor(page, url) {
    if (isVideoFile(url)) {
        pageLayout.pushToCurrent(page, PagesConstants.publish, { mediaUrl: String(url), isVideo: true })
    } else {
        pageLayout.pushToCurrent(page, PagesConstants.crop_photo, { imagePath: localPath(url) })
    }
}

function openPhotoEditor(page, imagePath, cropRect) {
    var encodedPath = imagePath.split('/').map(encodeURIComponent).join('/')
    imageproc.loadImage("image://photo/" + encodedPath + "?crop=true" + "&x=" + cropRect.x + "&y=" + cropRect.y + "&w=" + cropRect.width + "&h=" + cropRect.height)
    pageLayout.pushToCurrent(page, PagesConstants.edit_photo)
}

function openPhotoPublisher(page, imagePath) {
    pageLayout.pushToCurrent(page, PagesConstants.publish, { mediaUrl: "file://" + imagePath, isVideo: false })
}

function pushSingleImage(page, mediaId) {
    pageLayout.pushToCurrent(page, PagesConstants.photo, { photoId: mediaId })
}

function logOut() {
    if (loggedIn) {
        sessionViewModel.logout()
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

