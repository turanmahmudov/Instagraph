Qt.include("WorkerUtils.js")

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
        if (feed === 'StoriesTray') {
            obj[i].id = String(obj[i].id);
        }

        if (feed === 'ShareMediaPage') {
            obj[i].user_obj = typeof obj[i].user != 'undefined' ? obj[i].user : obj[i].thread.users[0];
        }

        model.append(removeEmptyMembers(obj[i]));
    }

    model.sync();
}
