WorkerScript.onMessage = function(msg) {
    // Get params from msg
    var obj = msg.obj;
    var model = msg.model;

    // Object loop
    for (var i = 0; i < obj.length; i++) {
        var story = obj[i];

        var act_text = story.args.text;
        var diff = 0;
        for (var j = 0; j < story.args.links.length; j++) {
            var linked_part = act_text.substring((story.args.links[j].start+diff), (story.args.links[j].end+diff));
            var rpl_with = '<a href="user://'+linked_part+'" style="text-decoration:none;font-weight:500;color:rgb(0,0,0);">'+linked_part+'</a>';
            act_text = act_text.replace(linked_part, rpl_with);
            diff = diff + rpl_with.length - linked_part.length;
        }

        model.append({"activity_text":act_text, "story":story});

        model.sync();
    }
}
