WorkerScript.onMessage = (message) => {
    const items = message.items
    const model = message.model
    const typeTexts = message.typeTexts

    if (message.clear) {
        model.clear()
    }

    items.forEach((item) => {
        let item_obj = {}

        item_obj.thread_id = item.thread_id
        item_obj.thread_title = item.thread_title !== "" ? item.thread_title : item.inviter.username
        item_obj.thread_text = getThreadText(item.last_permanent_item, message.activeUserId, typeTexts)
        item_obj.thread_time = item.last_permanent_item.timestamp
        item_obj.unseen = item.last_permanent_item.timestamp > item.last_seen_at[Object.keys(item.last_seen_at)[0]].timestamp
        item_obj.profile_pic_url = item.users.length > 0 ? item.users[0].profile_pic_url : item.inviter.profile_pic_url

        model.append(item_obj)

        model.sync()
    })
}

function getThreadText(item, activeUserId, typeTexts) {
    if (!item) return ""

    switch (item.item_type) {
        case 'media_share':
            return String(item.user_id) === String(activeUserId) ? typeTexts.you_shared_a_post : typeTexts.shared_a_post
        case 'media':
            return String(item.user_id) === String(activeUserId) ? typeTexts.you_shared_a_media : typeTexts.shared_a_media
        case 'story_share':
            return String(item.user_id) === String(activeUserId) ? typeTexts.you_sent_a_story : typeTexts.sent_a_story
        case 'link':
            return String(item.user_id) === String(activeUserId) ? typeTexts.you_shared_a_link : typeTexts.shared_a_link
        case 'like':
            return item.like
        case 'action_log':
            return item.action_log.description
        case 'placeholder':
            return item.placeholder.title
        case 'reel_share':
            if (item.reel_share.type === 'mention') {
                return String(item.user_id) === String(activeUserId) ? typeTexts.you_mentioned_them_in_a_story : typeTexts.mentioned_you_in_a_story
            }
            if (item.reel_share.type === 'reply') {
                return String(item.user_id) === String(activeUserId) ? typeTexts.you_replied_to_their_story : typeTexts.replied_to_your_story
            }
            return typeTexts.unknown
        default:
            return item.text || ""
    }
}
