WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;

    if (msg.suggestionsModel) {
        var suggestionsModel = msg.suggestionsModel;
    }

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {

        if (feed === "homePage") {

            var list_obj = {};

            // Stories Feed Tray
            if (msg.clear_model && i == 0) {
                list_obj.list_type = 'stories_feed';

                // Append to model
                model.append(list_obj);
            }

            if (typeof obj[i].suggested_users !== 'undefined') {
                // Suggestions
                for (var k = 0; k < obj[i].suggested_users.suggestions.length; k++) {
                    suggestionsModel.append(obj[i].suggested_users.suggestions[k]);
                    suggestionsModel.sync();
                }

                list_obj.list_type = 'suggested_users';

                // Append to model & sync
                model.append(list_obj);
                model.sync();
            } else if (typeof obj[i].media_or_ad !== 'undefined' && typeof obj[i].media_or_ad.injected !== 'undefined') {

            } else if (typeof obj[i].media_or_ad !== 'undefined' && typeof obj[i].media_or_ad.injected === 'undefined') {
                // Preview Comments
                for (var j = 0; j < obj[i].media_or_ad.preview_comments.length; j++) {
                    obj[i].media_or_ad.preview_comments[j].ctext = obj[i].media_or_ad.preview_comments[j].text;
                }

                // Carousel media
                obj[i].media_or_ad.carousel_media_obj = typeof obj[i].media_or_ad.carousel_media != 'undefined' ? obj[i].media_or_ad.carousel_media : []

                // Images
                obj[i].media_or_ad.images_obj = typeof obj[i].media_or_ad.image_versions2 != 'undefined' ? obj[i].media_or_ad.image_versions2 : {}

                // Video
                obj[i].media_or_ad.video_url = typeof obj[i].media_or_ad.video_versions != 'undefined' ? obj[i].media_or_ad.video_versions[0].url : ''

                list_obj = obj[i].media_or_ad;
                list_obj.list_type = 'media_entry';

                // Append to model & sync
                model.append(list_obj);
                model.sync();
            }

        } else if (feed === "savedMediaPage") {

            var list_obj = {};

            // Preview Comments
            for (var j = 0; j < obj[i].media.max_num_visible_preview_comments; j++) {
                if (typeof obj[i].media.preview_comments[j] !== 'undefined') {
                    obj[i].media.preview_comments[j].ctext = obj[i].media.preview_comments[j].text;
                }
            }

            // Photo Id
            obj[i].media.photo_id = obj[i].media.id;

            // Carousel media
            obj[i].media.carousel_media_obj = typeof obj[i].media.carousel_media != 'undefined' ? obj[i].media.carousel_media : []

            // Images
            obj[i].media.images_obj = typeof obj[i].media.image_versions2 != 'undefined' ? obj[i].media.image_versions2 : {}

            // Video
            if (feed !== 'searchPage') {
                obj[i].media.video_url = obj[i].media.video_versions ? obj[i].media.video_versions[0].url : ''
            }

            list_obj = obj[i].media;
            list_obj.list_type = 'media_entry';

            // Append to model & sync
            model.append(list_obj);
            model.sync();

        } else {

            var list_obj = {};

            // Preview Comments
            for (var j = 0; j < obj[i].max_num_visible_preview_comments; j++) {
                if (typeof obj[i].preview_comments[j] !== 'undefined') {
                    obj[i].preview_comments[j].ctext = obj[i].preview_comments[j].text;
                }
            }

            // Photo Id
            obj[i].photo_id = obj[i].id;

            // Carousel media
            obj[i].carousel_media_obj = typeof obj[i].carousel_media != 'undefined' ? obj[i].carousel_media : []

            // Images
            obj[i].images_obj = typeof obj[i].image_versions2 != 'undefined' ? obj[i].image_versions2 : {}

            // Video
            if (feed !== 'searchPage') {
                obj[i].video_url = obj[i].video_versions ? obj[i].video_versions[0].url : ''
            }

            list_obj = obj[i];
            list_obj.list_type = 'media_entry';

            // Append to model & sync
            model.append(list_obj);
            model.sync();

        }
    }
}
