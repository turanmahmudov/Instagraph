.pragma library

function calculateFlickDeceleration(gridUnit) {
    return 1500 * gridUnit / 8;
}

function calculateMaximumFlickVelocity(gridUnit) {
    return 2500 * gridUnit / 8;
}
