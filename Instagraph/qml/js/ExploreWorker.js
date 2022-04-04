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
        if (obj[i].layout_type === "two_by_two_right") {
            for (var j = 0; j < obj[i].layout_content.fill_items.length; j++) {
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

            for (var j = 0; j < obj[i].layout_content.fill_items.length; j++) {
                exploreObj = setMedia(obj[i].layout_content.fill_items[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                exploreObj.row = last_row + j
                exploreObj.column = 2
                model.append(exploreObj);
            }

            last_row += 2
        } else if (obj[i].layout_type === "media_grid") {
            for (var j = 0; j < obj[i].layout_content.medias.length; j++) {
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

    // Preview Comments
    list_obj.preview_comments = {}
    list_obj.preview_comments.comments = media.preview_comments
    for (var j = 0; j < media.max_num_visible_preview_comments; j++) {
        if (typeof media.preview_comments[j] !== 'undefined') {
            list_obj.preview_comments.comments[j].ctext = media.preview_comments[j].text
        }
    }

    // Carousel media
    list_obj.carousel_media_obj = {}
    list_obj.carousel_media_obj.media = typeof media.carousel_media != 'undefined' ? media.carousel_media : []

    // Images
    list_obj.images_obj = typeof media.image_versions2 != 'undefined' ? media.image_versions2 : {}

    // Video
    list_obj.video_url = typeof media.video_versions != 'undefined' ? media.video_versions[0].url : ''

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
