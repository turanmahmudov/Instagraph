WorkerScript.onMessage = (message) => {
    const items = message.items
    const model = message.model
    const is_caption = message.is_caption

    if (message.clear) {
        model.clear()
    }

    items.forEach((item) => {
        let item_obj = {}

        item_obj.is_caption = is_caption

        item_obj.pk = item.pk
        item_obj.comment_text = item.text ? item.text : ""
        item_obj.has_liked = item.has_liked_comment === true
        item_obj.like_count = item.comment_like_count ? item.comment_like_count : 0
        item_obj.user = item.user
        item_obj.created_at = item.created_at

        model.append(item_obj)
    })

    model.sync()
}
