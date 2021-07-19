import QtQuick 2.12
import Ubuntu.Components 1.3

Item {
    id: uriHandler

    Connections {
        target: UriHandler

        onOpened: {
            for (var i=0; i < uris.length; i++) {
                console.debug("URI=" + uris[i])
                uriHandler.process(uris[i]);
            }
        }
    }

    function process(uri) {
        // no process
        if (typeof uri === "undefined") return;

        if (loggedIn) {
            var commands = uri.split("://")[1].split("/");

            // no process
            if (commands[1] === "") return;

            if (commands[1] === "p") {
                // media
                return;
            } else if (commands[1] === "explore") {
                // no process
                if (commands[2] === "") return;
                if (commands[3] === "") return;

                if (commands[2] === "tags") {
                    //pageStack.push(Qt.resolvedUrl("qml/ui/TagFeedPage.qml"), {tag: commands[3]});
                } else if (commands[2] === "locations") {
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
}
