WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    if (msg.hasFollowRequests) {
        model.append({"list_type":"follow_requests"});
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        var story = obj[i];

        var act_text = "";

        // empty
        if (story.args && typeof story.args.links == 'undefined') {

            act_text = story.args.text;

            model.append({"activity_text":act_text, "story":story, "list_type":"recent_activity"});

        } else if (story.args && typeof story.args.links != 'undefined' && story.args.links.length > 0) {

            act_text = story.args.text;
            var linked_part = [];
            var linked_part_types = [];
            var linked_part_ids = [];

            for (var j = 0; j < story.args.links.length; j++) {
                linked_part[j] = act_text.substring((story.args.links[j].start), (story.args.links[j].end));
                linked_part_types[j] = story.args.links[j].type;
                linked_part_ids[j] = story.args.links[j].id;
            }

            for (var k = 0; k < linked_part.length; k++) {
                if (linked_part_types[k] == "like_count_chrono") {
                    var rpl_with = '<a href="likes://'+linked_part[k]+'" style="text-decoration:none;font-weight:500;color:'+msg.textColor+';">'+linked_part[k]+'</a>';
                    act_text = act_text.replace(linked_part[k], rpl_with);
                } else if (linked_part_types[k] == "user") {
                    var rpl_with = '<a href="userid://'+linked_part_ids[k]+'" style="text-decoration:none;font-weight:500;color:'+msg.textColor+';">'+linked_part[k]+'</a>';
                    act_text = act_text.replace(linked_part[k], rpl_with);
                }
            }

            model.append({"activity_text":act_text, "story":story, "list_type":"recent_activity"});

        }

        model.sync();
    }
}
