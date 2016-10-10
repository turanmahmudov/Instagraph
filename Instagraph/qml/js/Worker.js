WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;
    if (msg.commentsModel) {
        var commentsModel = msg.commentsModel;
    }
    if (msg.suggestionsModel) {
        var suggestionsModel = msg.suggestionsModel;
    }

    if (msg.clear_model) {
        model.clear();
        if (msg.commentsModel) {
            commentsModel.clear();
        }
        if (msg.suggestionsModel) {
            suggestionsModel.clear();
        }
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        // Suggestions
        //suggestionsModel.append(obj[i]);
        //suggestionsModel.sync();


        if (feed == 'homePage') {
            if (typeof obj[i].media_or_ad != 'undefined') {

                obj[i].media_or_ad.video_url = typeof obj[i].media_or_ad.video_versions != 'undefined' ? obj[i].media_or_ad.video_versions[0].url : ''

                model.append(obj[i].media_or_ad);

                if (msg.commentsModel) {
                    if (obj[i].media_or_ad.comment_count != 0) {
                        for (var j = 0; j < obj[i].media_or_ad.max_num_visible_preview_comments; j++) {
                            commentsModel.append({"c_image_id": obj[i].media_or_ad.pk, "comment": obj[i].media_or_ad.preview_comments[j]});
                            commentsModel.sync();
                        }
                    }
                }

                model.sync();
            }
        } else {
            if (feed != 'searchPage') {
                obj[i].video_url = obj[i].video_versions ? obj[i].video_versions[0].url : ''
            }

            model.append(obj[i]);

            if (msg.commentsModel) {
                if (obj[i].comment_count != 0) {
                    for (var j = 0; j < obj[i].max_num_visible_preview_comments; j++) {
                        commentsModel.append({"c_image_id": obj[i].pk, "comment": obj[i].preview_comments[j]});
                        commentsModel.sync();
                    }
                }
            }

            model.sync();
        }
    }
}
