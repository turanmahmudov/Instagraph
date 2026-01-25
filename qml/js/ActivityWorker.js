WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    if (msg.hasFollowRequests) {
        model.append({"list_type": "follow_requests"});
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        // time bucket headers
        var header = ""
        if (msg.old === true && "time_bucket" in msg.partition) {
            for (var h = 0; h < msg.partition.time_bucket.headers.length; h++) {
                if (i === msg.partition.time_bucket.indices[h]) {
                    header = msg.partition.time_bucket.headers[h]
                }
            }
        }

        var story = obj[i]

        var list_obj = generateListObj(story)
        list_obj.header = header

        // empty
        if (story.args && !("links" in story.args)) {
            if ("rich_text" in story.args) {
                list_obj.activity_text = story.args.rich_text
            } else {
                list_obj.activity_text = story.args.text
            }
        } else if (story.args && "links" in story.args && story.args.links.length > 0) {
            var act_text = story.args.text;
            var linked_part = [];
            var linked_part_types = [];
            var linked_part_ids = [];

            for (var j = 0; j < story.args.links.length; j++) {
                linked_part[j] = act_text.substring((story.args.links[j].start), (story.args.links[j].end));
                linked_part_types[j] = story.args.links[j].type;
                linked_part_ids[j] = story.args.links[j].id;
            }

            for (var k = 0; k < linked_part.length; k++) {
                var rpl_with
                if (linked_part_types[k] === "like_count_chrono") {
                    rpl_with = '<a href="likes://'+linked_part[k]+'" style="text-decoration:none;font-weight:500;color:'+msg.textColor+';">'+linked_part[k]+'</a>';
                    act_text = act_text.replace(linked_part[k], rpl_with);
                } else if (linked_part_types[k] === "user") {
                    rpl_with = '<a href="userid://'+linked_part_ids[k]+'" style="text-decoration:none;font-weight:500;color:'+msg.textColor+';">'+linked_part[k]+'</a>';
                    act_text = act_text.replace(linked_part[k], rpl_with);
                }
            }

            list_obj.activity_text = act_text

        }

        model.append(list_obj);
        model.sync();
    }
}

function generateListObj(story) {
    var list_obj = {}

    list_obj.story_type = story.type
    if ("profile_image" in story.args) list_obj.profile_image = story.args.profile_image
    if ("profile_id" in story.args) list_obj.profile_id = story.args.profile_id
    if ("media" in story.args) list_obj.media = story.args.media[0]
    if ("inline_follow" in story.args) list_obj.inline_follow = story.args.inline_follow
    list_obj.timestamp = story.args.timestamp
    list_obj.story = story
    list_obj.list_type = "recent_activity"

    return list_obj
}
