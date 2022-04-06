var last_row = 0
WorkerScript.onMessage = function(msg) {
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    var exploreObj
    for (var i = 0; i < obj.length; i++) {
        var j = 0
        if (obj[i].layout_type === "two_by_two_right") {
            for (j = 0; j < obj[i].layout_content.fill_items.length; j++) {
                exploreObj = setMedia(obj[i].layout_content.fill_items[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                exploreObj.row = last_row + j
                exploreObj.column = 0
                model.append(exploreObj);
            }

            exploreObj = extractMediaObjFromTwoByTwo(obj[i].layout_content.two_by_two_item)
            exploreObj.rowSpan = 2
            exploreObj.columnSpan = 2
            exploreObj.row = last_row
            exploreObj.column = 1
            model.append(exploreObj);

            last_row += 2
        } else if (obj[i].layout_type === "two_by_two_left") {
            exploreObj = extractMediaObjFromTwoByTwo(obj[i].layout_content.two_by_two_item)
            exploreObj.rowSpan = 2
            exploreObj.columnSpan = 2
            exploreObj.row = last_row
            exploreObj.column = 0
            model.append(exploreObj);

            for (j = 0; j < obj[i].layout_content.fill_items.length; j++) {
                exploreObj = setMedia(obj[i].layout_content.fill_items[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                exploreObj.row = last_row + j
                exploreObj.column = 2
                model.append(exploreObj);
            }

            last_row += 2
        } else if (obj[i].layout_type === "media_grid") {
            for (j = 0; j < obj[i].layout_content.medias.length; j++) {
                exploreObj = setMedia(obj[i].layout_content.medias[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                exploreObj.row = last_row
                exploreObj.column = 0 + j
                model.append(exploreObj);
            }

            last_row += 1
        }

        model.sync();
    }
}

function setMedia(media) {
    var list_obj = {}
    list_obj.photo_id = media.id

    // Carousel media
    list_obj.carousel_media_obj = {}
    list_obj.carousel_media_obj.media = "carousel_media" in media ? media.carousel_media : []

    // Images
    list_obj.images_obj = "image_versions2" in media ? media.image_versions2 : {}

    // Video
    list_obj.video_url = "video_versions" in media ? media.video_versions[0].url : ''

    list_obj.media_type = media.media_type
    list_obj.list_type = 'media_entry';

    return list_obj
}

function extractMediaObjFromTwoByTwo(obj) {
    if ("channel" in obj) {
         return setMedia(obj.channel.media)
    } else if ("igtv" in obj) {
        return setMedia(obj.igtv.media)
    } else {
        return setMedia(obj.media)
    }
}
