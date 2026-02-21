WorkerScript.onMessage = (message) => {
    const feed_items = message.feed_items
    const feed_model = message.feed_model

    let suggestions_model = null
    if (message.suggestions_model) {
        suggestions_model = message.suggestions_model
    }

    if (message.clear) {
        feed_model.clear()
    }

    feed_items.forEach((feed_item, i) => {
        let feed_item_obj = {}

        // Stories feed tray
        if (message.clear && i === 0) {
            feed_item_obj.list_type = 'stories_feed'
            feed_model.append(feed_item_obj)
        }

        if ("suggested_users" in feed_item && "suggestions" in feed_item.suggested_users) {
            feed_item.suggested_users.suggestions.forEach((user) => {
                suggestions_model.append(user)
            })

            feed_item_obj.list_type = 'suggested_users'
            feed_model.append(feed_item_obj)
        } else if ("media_or_ad" in feed_item && !("injected" in feed_item.media_or_ad)) {
            const media = feed_item.media_or_ad

            feed_item_obj.id = media.id
            feed_item_obj.photo_id = media.id
            feed_item_obj.code = media.code
            feed_item_obj.photo_of_you = media.photo_of_you
            feed_item_obj.media_type = media.media_type
            feed_item_obj.has_liked = media.has_liked
            feed_item_obj.like_count = media.like_count.toLocaleString()
            feed_item_obj.taken_at = media.taken_at
            feed_item_obj.caption = media.caption
            feed_item_obj.has_more_comments = media.has_more_comments
            feed_item_obj.comment_count = media.comment_count
            feed_item_obj.comments_disabled = media.comments_disabled
            feed_item_obj.location = media.location
            feed_item_obj.user = media.user

            // Preview Comments
            feed_item_obj.preview_comments = {
                "comments": media.preview_comments ? media.preview_comments : []
            }
            feed_item_obj.preview_comments.comments.forEach((comment) => {
                comment.ctext = comment.text
            })

            // Carousel Media
            feed_item_obj.carousel_media_obj = {
                "media": "carousel_media" in media ? media.carousel_media : []
            }

            // Images
            feed_item_obj.images_obj = "image_versions2" in media ? media.image_versions2 : {}

            // Videos
            feed_item_obj.video_url = "video_versions" in media ? media.video_versions[0].url : ''

            feed_item_obj.list_type = 'media_entry'
            feed_model.append(feed_item_obj)

            // Seen posts
            WorkerScript.sendMessage({ id: media.id, type: "seen_posts" })
        } else if ("end_of_feed_demarcator" in feed_item && feed_item.end_of_feed_demarcator.pause) {
            // Pause
            WorkerScript.sendMessage({ type: "pause" })
        }
    })
    
    // Sync once at the end after all items are appended
    if (suggestions_model) {
        suggestions_model.sync()
    }
    feed_model.sync()
}
