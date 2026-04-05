WorkerScript.onMessage = (message) => {
    const items = message.items
    const model = message.model

    if (message.clear) {
        model.clear()
    }

    items.forEach((item, i) => {
        let item_obj = {}
        item_obj.user = item

        model.append(item_obj)
        model.sync()
    })
}
