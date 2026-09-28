import QtQuick 2.12
import Lomiri.Components 1.3

import "../viewmodels"

Rectangle {
    id: mentionSuggestions

    property Item field

    property bool hasQuery: false

    visible: hasQuery && viewModel.suggestionsModel.count > 0
    height: visible ? suggestionsColumn.height : 0
    color: styleApp.common.backgroundColor

    MentionSuggestionsViewModel {
        id: viewModel
    }

    function updateQuery() {
        if (!field) {
            return;
        }

        var match = field.text.substring(0, field.cursorPosition).match(/(^|\s)@([\w.]*)$/);
        hasQuery = match !== null;
        if (hasQuery) {
            viewModel.filter(match[2]);
        }
    }

    function insertMention(username) {
        var before = field.text.substring(0, field.cursorPosition);
        var after = field.text.substring(field.cursorPosition);
        var start = before.lastIndexOf("@");
        field.text = before.substring(0, start) + "@" + username + " " + after;
        field.cursorPosition = start + username.length + 2;
        hasQuery = false;
    }

    Connections {
        target: field
        function onTextChanged() {
            updateQuery();
        }
        function onCursorPositionChanged() {
            updateQuery();
        }
    }

    Rectangle {
        width: parent.width
        height: units.dp(1)
        color: styleApp.common.baseBorderColor
    }

    Column {
        id: suggestionsColumn
        width: parent.width

        Repeater {
            model: viewModel.suggestionsModel

            ListItem {
                width: suggestionsColumn.width
                height: suggestionLayout.height
                divider.visible: false
                onClicked: insertMention(username)

                ListItemLayout {
                    id: suggestionLayout
                    title.text: username
                    title.font.weight: Font.DemiBold
                    subtitle.text: full_name

                    CircleImage {
                        width: units.gu(4)
                        height: width
                        source: profile_pic_url
                        SlotsLayout.position: SlotsLayout.Leading
                    }
                }
            }
        }
    }
}
