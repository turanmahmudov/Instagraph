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
