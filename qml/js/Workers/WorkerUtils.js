function removeEmptyMembers(value) {
    if (Array.isArray(value)) {
        return value.map(removeEmptyMembers)
    }

    if (value !== null && typeof value === "object") {
        const result = {}
        Object.keys(value).forEach((key) => {
            if (value[key] !== null && value[key] !== undefined) {
                result[key] = removeEmptyMembers(value[key])
            }
        })
        return result
    }

    return value
}

function isThreadUnread(thread, viewerId) {
    const item = thread.last_permanent_item
    if (!item || String(item.user_id) === String(viewerId)) {
        return false
    }

    const seen = (thread.last_seen_at || {})[String(viewerId)]
    return !seen || Number(item.timestamp) > Number(seen.timestamp)
}
