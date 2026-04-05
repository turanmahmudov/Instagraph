pragma Singleton
import QtQuick 2.12

QtObject {
    // LineIcons 4.0
    // Central icon constants to replace hardcoded unicode strings

    // Navigation
    readonly property string back: "\ueb1b"
    readonly property string chevron_left: "\ueb0f"
    readonly property string chevron_down: "\ueb11"
    readonly property string home: "\uea81"
    readonly property string search: "\uea17"
    readonly property string inbox: "\ueaec"
    readonly property string envelope: "\ueb5c"

    // Actions
    readonly property string cog: "\uea3e"
    readonly property string comments: "\uea74"
    readonly property string liked: "\ueadf"
    readonly property string unliked: "\ueae1"
    readonly property string save: "\uead1"
    readonly property string share: "\ueb80"
    readonly property string plus: "\ueab8"
    readonly property string plus_circle: "\ueacf"
    readonly property string popup: "\ueb2e"
    readonly property string remove: "\uec81"
    readonly property string x_close: "\ueace"

    // Media
    readonly property string gallery: "\ueaa0"
    readonly property string image: "\uea2e"
    readonly property string video: "\uf048"
    readonly property string hashtag: "\uEFC7"
    readonly property string location: "\uea27"

    // User/Profile
    readonly property string users: "\uea07"
    readonly property string user_list: "\uefbb"
    readonly property string user_grid: "\ueb2e"
    readonly property string user_tags: "\ueddd"
    readonly property string user_saved: "\uefd4"

    // Additional icons found in Instagraph
    readonly property string settings: "\uea6f"      // Settings/options icon
    readonly property string people_add: "\uebdf"    // Add people/suggestions icon
    readonly property string heart_filled: "\ueaeb"  // Filled heart icon
    readonly property string bookmark: "\ueab0"      // Bookmark/save icon
    readonly property string forward: "\ueb17"       // Forward/share icon
    readonly property string camera_flip: "\uea55"   // Camera flip icon
    readonly property string flash_on: "\uea5a"      // Flash on icon
    readonly property string flash_off: "\uea5c"     // Flash off icon
    readonly property string timer: "\uea63"         // Timer icon
    readonly property string mic: "\ueb48"           // Microphone icon
    readonly property string icon_eaab: "\ueaab"     // Unknown
    readonly property string icon_eb6d: "\ueb6d"     // Unknown
}
