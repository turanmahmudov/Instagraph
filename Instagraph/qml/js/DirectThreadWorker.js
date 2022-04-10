WorkerScript.onMessage = function(msg) {
    var obj = msg.obj;
    var model = msg.model;
    var type = msg.type;

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        var listObj = {}
        listObj.item_type = obj[i].item_type
        listObj.user_id = obj[i].user_id
        listObj.item_id = obj[i].item_id

        listObj.cText = obj[i].text

        listObj.options = {}
        listObj.media = {}
        listObj.link = {}
        listObj.placeholder = {}
        listObj.media_share = {}
        listObj.reel_share = {}
        listObj.story_share = {}

        switch (obj[i].item_type) {
            case "animated_media":
                listObj.media = obj[i].animated_media
                break;
            case "raven_media":
                listObj.options.raven_media_expired = !("image_versions2" in obj[i].visual_media.media)
                listObj.media = obj[i].visual_media
                break;
            case "link":
                listObj.link = obj[i].link
                break;
            case "placeholder":
                listObj.placeholder = obj[i].placeholder
                break;
            case "media":
                listObj.media = obj[i].media
                break;
            case "media_share":
                listObj.media_share = obj[i].media_share
                break;
            case "reel_share":
                listObj.reel_share = obj[i].reel_share
                break;
            case "story_share":
                listObj.story_share = obj[i].story_share
                break;

            default:

        }

        if (msg.insert) {
            WorkerScript.sendMessage(listObj)
        } else {
            model.append(listObj);
            model.sync();
        }

    }
}
