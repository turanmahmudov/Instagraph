WorkerScript.onMessage = function(msg) {
    var obj = msg.obj;
    var model = msg.model;
    var type = msg.type;

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        if (type === "recentSearches") {
            if ("user" in obj[i]) {
                obj[i].search_type = "user"

                obj[i].pk = obj[i].user.pk
                obj[i].user_id = obj[i].user.pk
                obj[i].username = obj[i].user.username
                obj[i].full_name = obj[i].user.full_name
                obj[i].profile_pic_url = obj[i].user.profile_pic_url

                model.append(obj[i]);
            } else if ("keyword" in obj[i]) {
                obj[i].search_type = "keyword"

                obj[i].name = obj[i].keyword.name

                model.append(obj[i]);
            }
        } else if (type === "searchUsers") {
            obj[i].pk = obj[i].pk
            obj[i].user_id = obj[i].pk
            obj[i].username = obj[i].username
            obj[i].full_name = obj[i].full_name
            obj[i].profile_pic_url = obj[i].profile_pic_url

            model.append(obj[i]);
        } else if (type === "searchTags") {
            obj[i].name = obj[i].name
            obj[i].media_count = obj[i].media_count

            model.append(obj[i]);
        } else if (type === "searchLocation") {
            obj[i].pk = obj[i].location.pk
            obj[i].title = obj[i].title
            obj[i].subtitle = obj[i].subtitle

            model.append(obj[i]);
        }

        model.sync();
    }
}
