WorkerScript.onMessage = function(msg) {
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;

    if (msg.suggestionsModel) {
        var suggestionsModel = msg.suggestionsModel;
    }

    if (msg.clear_model) {
        model.clear();
    }

    for (var i = 0; i < obj.length; i++) {
        var list_obj = {};

        if (feed === "homePage") {
            // Stories Feed Tray
            if (msg.clear_model && i === 0) {
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
            } else if (typeof obj[i].media_or_ad !== 'undefined' && typeof obj[i].media_or_ad.injected === 'undefined') {
                var media = obj[i].media_or_ad

                list_obj.id = media.id
                list_obj.photo_id = media.id
                list_obj.code = media.code
                list_obj.photo_of_you = media.photo_of_you
                list_obj.media_type = media.media_type
                list_obj.has_liked = media.has_liked
                list_obj.like_count = media.like_count.toLocaleString()
                list_obj.taken_at = media.taken_at
                list_obj.caption = media.caption
                list_obj.has_more_comments = media.has_more_comments
                list_obj.comment_count = media.comment_count
                list_obj.comments_disabled = media.comments_disabled
                list_obj.location = media.location
                list_obj.user = media.user

                // Preview Comments
                list_obj.preview_comments = {}
                list_obj.preview_comments.comments = media.preview_comments
                for (var j = 0; j < media.preview_comments.length; j++) {
                    list_obj.preview_comments.comments[j].ctext = media.preview_comments[j].text
                }

                // Carousel media
                list_obj.carousel_media_obj = {}
                list_obj.carousel_media_obj.media = typeof media.carousel_media != 'undefined' ? media.carousel_media : []

                // Images
                list_obj.images_obj = typeof media.image_versions2 != 'undefined' ? media.image_versions2 : {}

                // Video
                list_obj.video_url = typeof media.video_versions != 'undefined' ? media.video_versions[0].url : ''

                list_obj.list_type = 'media_entry';

                // Append to model & sync
                model.append(list_obj);
                model.sync();
            }
        } else if (feed === "savedMediaPage") {
            var media = obj[i].media

            list_obj.id = media.id
            list_obj.photo_id = media.id
            list_obj.code = media.code
            list_obj.photo_of_you = media.photo_of_you
            list_obj.media_type = media.media_type
            list_obj.has_liked = media.has_liked
            list_obj.like_count = media.like_count.toLocaleString()
            list_obj.taken_at = media.taken_at
            list_obj.caption = media.caption
            list_obj.has_more_comments = media.has_more_comments
            list_obj.comment_count = media.comment_count
            list_obj.comments_disabled = media.comments_disabled

            list_obj.user = media.user

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

            list_obj.list_type = 'media_entry';

            // Append to model & sync
            model.append(list_obj);
            model.sync();
        } else {
            var media = obj[i]

            list_obj = media
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

            list_obj.list_type = 'media_entry';

            // Append to model & sync
            model.append(list_obj);
            model.sync();
        }
    }
}
