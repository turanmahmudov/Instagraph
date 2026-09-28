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
            feed_item_obj.can_view_more_preview_comments = media.can_view_more_preview_comments
            feed_item_obj.comment_count = media.comment_count
            feed_item_obj.comments_disabled = media.comments_disabled
            feed_item_obj.has_viewer_saved = media.has_viewer_saved === true
            feed_item_obj.location = media.location || { name: "" }
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
        } else if ("end_of_feed_demarcator" in feed_item) {
            const demarcator = feed_item.end_of_feed_demarcator

            // Check if there are suggested posts in group_set
            if (demarcator.group_set && demarcator.group_set.groups && demarcator.group_set.groups.length > 0) {
                const group = demarcator.group_set.groups[0]
                if (group.feed_items && group.feed_items.length > 0) {
                    // Add a separator for suggested posts
                    feed_model.append({
                        list_type: 'suggested_posts_header',
                        title: demarcator.title || "Suggested for you",
                        subtitle: demarcator.subtitle || ""
                    })

                    // Process suggested posts (explore_story items)
                    group.feed_items.forEach((suggested_item) => {
                        if ("explore_story" in suggested_item && "media_or_ad" in suggested_item.explore_story) {
                            const media = suggested_item.explore_story.media_or_ad

                            let suggested_feed_item = {}
                            suggested_feed_item.id = media.id
                            suggested_feed_item.photo_id = media.id
                            suggested_feed_item.code = media.code
                            suggested_feed_item.photo_of_you = media.photo_of_you || false
                            suggested_feed_item.media_type = media.media_type
                            suggested_feed_item.has_liked = media.has_liked || false
                            suggested_feed_item.like_count = media.like_count ? media.like_count.toLocaleString() : "0"
                            suggested_feed_item.taken_at = media.taken_at
                            suggested_feed_item.caption = media.caption || { text: "", user: { username: "" } }
                            suggested_feed_item.can_view_more_preview_comments = media.can_view_more_preview_comments || false
                            suggested_feed_item.comment_count = media.comment_count || 0
                            suggested_feed_item.comments_disabled = media.comments_disabled || false
                            suggested_feed_item.has_viewer_saved = media.has_viewer_saved === true
                            suggested_feed_item.location = media.location || { name: "" }
                            suggested_feed_item.user = media.user

                            // Preview Comments
                            suggested_feed_item.preview_comments = {
                                "comments": media.preview_comments ? media.preview_comments : []
                            }
                            suggested_feed_item.preview_comments.comments.forEach((comment) => {
                                comment.ctext = comment.text
                            })

                            // Carousel Media
                            suggested_feed_item.carousel_media_obj = {
                                "media": "carousel_media" in media ? media.carousel_media : []
                            }

                            // Images
                            suggested_feed_item.images_obj = "image_versions2" in media ? media.image_versions2 : {}

                            // Videos
                            suggested_feed_item.video_url = "video_versions" in media ? media.video_versions[0].url : ''

                            suggested_feed_item.list_type = 'media_entry'
                            feed_model.append(suggested_feed_item)

                            // Seen posts
                            WorkerScript.sendMessage({ id: media.id, type: "seen_posts" })
                        }
                    })
                }
            }

            // Send end of feed info with title and subtitle
            WorkerScript.sendMessage({
                type: "end_of_feed",
                title: demarcator.title || "",
                subtitle: demarcator.subtitle || "",
                pause: demarcator.pause || false,
                style: demarcator.style || ""
            })
        }
    })

    // Sync once at the end after all items are appended
    if (suggestions_model) {
        suggestions_model.sync()
    }
    feed_model.sync()

    // Signal that worker finished processing
    WorkerScript.sendMessage({ type: "done" })
}
