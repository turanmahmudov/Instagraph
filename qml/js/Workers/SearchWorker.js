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

                // Keep the user object intact for UserRowSlot
                model.append(obj[i]);
            } else if ("keyword" in obj[i]) {
                obj[i].search_type = "keyword"
                obj[i].name = obj[i].keyword.name

                model.append(obj[i]);
            }
        } else if (type === "searchUsers") {
            var user_obj = {
                user: {
                    pk: obj[i].pk,
                    username: obj[i].username,
                    full_name: obj[i].full_name,
                    profile_pic_url: obj[i].profile_pic_url
                }
            }
            user_obj.pk = obj[i].pk
            user_obj.user_id = obj[i].pk

            model.append(user_obj);
        } else if (type === "searchTags") {
            obj[i].name = obj[i].name
            obj[i].media_count = obj[i].media_count

            model.append(obj[i]);
        } else if (type === "searchLocation") {
            obj[i].pk = obj[i].location.pk
            obj[i].title = obj[i].title
            obj[i].subtitle = obj[i].subtitle

            model.append(obj[i]);
        } else if (type === "searchVenues") {
            model.append(obj[i]);
        }

        model.sync();
    }
}
