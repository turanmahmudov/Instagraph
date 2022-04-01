WorkerScript.onMessage = function(msg) {
    var obj = msg.obj;
    var model = msg.model;

    if (msg.clear_model) {
        model.clear();
    }

    // Object loop
    for (var i = 0; i < obj.length; i++) {


        model.append(obj[i]);

        model.sync();
    }
}
