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
        listObj.animated_media = {}
        listObj.link = {}
        listObj.placeholder = {}
        listObj.media_share = {}
        listObj.reel_share = {}
        listObj.story_share = {}
        listObj.xma_media_share = {}

        switch (obj[i].item_type) {
            case "animated_media":
                var am = obj[i].animated_media || {}
                var fh = (am.images && am.images.fixed_height) ? am.images.fixed_height : {}
                listObj.animated_media = {
                    is_sticker: am.is_sticker || false,
                    url: fh.url || "",
                    width: fh.width || "0",
                    height: fh.height || "0"
                }
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
            case "store_sticker":
                var sticker = obj[i].store_sticker || {}
                listObj.item_type = "animated_media"
                listObj.animated_media = {
                    is_sticker: true,
                    url: sticker.image_url || "",
                    width: String(sticker.image_width || 0),
                    height: String(sticker.image_height || 0)
                }
                break;

            default:
                var xma = obj[i][obj[i].item_type]
                if (obj[i].item_type.indexOf("xma") !== -1 && xma && xma.length > 0) {
                    listObj.item_type = "xma_media_share"
                    listObj.xma_media_share = xma[0]
                }
        }

        if (msg.insert) {
            WorkerScript.sendMessage(listObj)
        } else {
            model.append(listObj);
            model.sync();
        }

    }
}
