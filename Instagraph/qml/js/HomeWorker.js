WorkerScript.onMessage = function(msg) {
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

        // Stories Feed Tray
        if (msg.clear_model && i === 0) {
            list_obj.list_type = 'stories_feed';

            // Append to model
            model.append(list_obj);
        }

        // Suggestions
        if ("suggested_users" in obj[i] && "suggestions" in obj[i].suggested_users) {
            for (var k = 0; k < obj[i].suggested_users.suggestions.length; k++) {
                suggestionsModel.append(obj[i].suggested_users.suggestions[k]);
                suggestionsModel.sync();
            }

            list_obj.list_type = 'suggested_users';

            model.append(list_obj);
            model.sync();
        } else if ("media_or_ad" in obj[i] && !("injected" in obj[i].media_or_ad)) {
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
            list_obj.carousel_media_obj.media = "carousel_media" in media ? media.carousel_media : []

            // Images
            list_obj.images_obj = "image_versions2" in media ? media.image_versions2 : {}

            // Video
            list_obj.video_url = "video_versions" in media ? media.video_versions[0].url : ''

            list_obj.list_type = 'media_entry';

            model.append(list_obj);
            model.sync();
        }
    }
}
