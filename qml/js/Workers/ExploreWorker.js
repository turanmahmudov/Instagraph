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
        } else if (obj[i].layout_type === "one_by_two_right") {
            // New layout: 4 fill items on the left (2 rows x 2 columns), 1 hero clip on the right (2 rows tall)
            var fillItems = obj[i].layout_content.fill_items || []
            for (j = 0; j < fillItems.length && j < 4; j++) {
                exploreObj = setMedia(fillItems[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                // Place in a 2x2 grid on the left: row 0-1, columns 0-1
                exploreObj.row = last_row + Math.floor(j / 2)
                exploreObj.column = j % 2
                model.append(exploreObj);
            }

            // Hero clip on the right side (spanning 2 rows, 1 column)
            exploreObj = extractMediaObjFromOneByTwo(obj[i].layout_content.one_by_two_item)
            if (exploreObj) {
                exploreObj.rowSpan = 2
                exploreObj.columnSpan = 1
                exploreObj.row = last_row
                exploreObj.column = 2
                model.append(exploreObj);
            }

            last_row += 2
        } else if (obj[i].layout_type === "one_by_two_left") {
            // New layout: 1 hero clip on the left (2 rows tall), 4 fill items on the right (2 rows x 2 columns)
            exploreObj = extractMediaObjFromOneByTwo(obj[i].layout_content.one_by_two_item)
            if (exploreObj) {
                exploreObj.rowSpan = 2
                exploreObj.columnSpan = 1
                exploreObj.row = last_row
                exploreObj.column = 0
                model.append(exploreObj);
            }

            var fillItemsLeft = obj[i].layout_content.fill_items || []
            for (j = 0; j < fillItemsLeft.length && j < 4; j++) {
                exploreObj = setMedia(fillItemsLeft[j].media)
                exploreObj.rowSpan = 1
                exploreObj.columnSpan = 1
                // Place in a 2x2 grid on the right: row 0-1, columns 1-2
                exploreObj.row = last_row + Math.floor(j / 2)
                exploreObj.column = 1 + (j % 2)
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

function extractMediaObjFromOneByTwo(obj) {
    if (!obj) return null

    // New format: clips container with items array
    if ("clips" in obj && obj.clips.items && obj.clips.items.length > 0) {
        return setMedia(obj.clips.items[0].media)
    }

    // Fallback: direct media object
    if ("media" in obj) {
        return setMedia(obj.media)
    }

    return null
}
