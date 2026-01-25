import QtQuick 2.12
import Lomiri.Components 1.3

PageHeader {
    id: pageheader
    property list<Action> trailingActions
    property list<Action> leadingActions

    property bool noBackAction: false

    property bool whiteIcons: false

    StyleHints {
        backgroundColor: styleApp.pageHeader.backgroundColor
        dividerColor: styleApp.pageHeader.dividerColor
    }

    leadingActionBar {
        actions: leadingActions.length == 0 && !noBackAction ? pageheader.navigationActions : leadingActions
        delegate: ActionLineIconDelegate {
            model: modelData
            iconSize: units.gu(1.5)
            customIconColor: whiteIcons ? styleApp.common.white : styleApp.common.iconActiveColor
        }
    }

    trailingActionBar {
        numberOfSlots: trailingActions.length
        actions: trailingActions
        delegate: ActionLineIconDelegate {
            model: modelData
            iconSize: units.gu(1.5)
            customIconColor: whiteIcons ? styleApp.common.white : styleApp.common.iconActiveColor
        }
    }
}
