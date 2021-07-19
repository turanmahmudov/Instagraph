pragma Singleton

import QtQuick 2.12

Item {
    id: fonts

    readonly property FontLoader lineIcons: FontLoader {
        source: "LineIcons.ttf"
    }

    readonly property string icons: fonts.lineIcons.name
}
