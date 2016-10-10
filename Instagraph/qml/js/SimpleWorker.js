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
        }

        model.append(obj[i]);

        model.sync();
    }
}
