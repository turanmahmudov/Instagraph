WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var feed = msg.feed;
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        if (feed == 'CommentsPage') {
            obj[i].ctext = obj[i].text ? obj[i].text : "";

            obj[i].has_liked_c = obj[i].has_liked_comment == true ? true : false
            obj[i].comment_like_c = obj[i].comment_like_count ? obj[i].comment_like_count : 0
        }

        if (feed == 'discoverPeoplePage') {
            if (typeof obj[i].media == 'undefined') {
                continue;
            }
        }

        if (feed == 'ShareMediaPage') {
            obj[i].user_obj = typeof obj[i].user != 'undefined' ? obj[i].user : obj[i].thread.users[0];
        }

        model.append(obj[i]);

        model.sync();
    }
}
