function linkClick(link, photoId) {
    var result = link.split("://");
    if(result[0] == "user") {
        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameString: result[1]});
    } else if(result[0] == "userid") {
        pageStack.push(Qt.resolvedUrl("../ui/OtherUserPage.qml"), {usernameId: result[1]});
    } else if(result[0] == "tag") {
        pageStack.push(Qt.resolvedUrl("../ui/TagFeedPage.qml"), {tag: result[1]});
    } else if(result[0] == "likes") {
        pageStack.push(Qt.resolvedUrl("../ui/MediaLikersPage.qml"), {photoId: photoId});
    } else {
        Qt.openUrlExternally(link)
    }
}

function pushImageEdit(url) {
    pageStack.push(Qt.resolvedUrl("../ui/CameraEditPage.qml"))

    var r = {
        "x": 0,
        "y": 0,
        "width": 1,
        "height": 1
    }

    imageproc.loadImage("image://photo/" + String(url).replace('file://', '') + "?crop=true" + "&x="+ r.x + "&y=" + r.y +"&w=" + r.width + "&h=" + r.height);
}

function pushImageCaption(url) {
    pageStack.push(Qt.resolvedUrl("../ui/CameraCaptionPage.qml"), {imagePath: String(url).replace('file://', '')})
}

function pushImageCrop(url) {
    pageStack.push(Qt.resolvedUrl("../ui/CameraCropPage.qml"), {imagePath: String(url).replace('file://', '')})
}

function pushSingleImage(mediaId) {
    pageStack.push(Qt.resolvedUrl("../ui/SinglePhoto.qml"), {photoId: mediaId})
}

function publishImage(url, caption, location) {
    instagram.postImage(String(url).replace('file://', ''), caption, location);
}

function logOut() {
    instagram.logout()

    Storage.set("password", "");
    Storage.set("username", "")

    pageStack.clear();
    init()
}

function registered() {
    instagram.logout()

    pageStack.clear();
    init()
}
