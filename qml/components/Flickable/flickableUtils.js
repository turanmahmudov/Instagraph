.pragma library

function calculateFlickDeceleration(gridUnit) {
    return 1500 * gridUnit / 8;
}

function calculateMaximumFlickVelocity(gridUnit) {
    return 2500 * gridUnit / 8;
}

function isNearEnd(flickable, growsUpward) {
    var distance = growsUpward ? flickable.contentY - flickable.originY : flickable.originY + flickable.contentHeight - flickable.contentY - flickable.height;
    return distance < flickable.height * 4;
}
