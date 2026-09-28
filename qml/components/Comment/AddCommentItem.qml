import QtQuick 2.12
import ".."
import Lomiri.Components 1.3

import "../../js/Helper.js" as Helper

Item {
    signal commentPosted(string text)

    function prepareReply(username) {
        addCommentField.forceActiveFocus();
        addCommentField.text = `@${username} `;
    }

    function clear() {
        addCommentField.text = "";
    }

    Row {
        width: parent.width
        spacing: units.gu(1)

        TextField {
            id: addCommentField
            width: parent.width - addCommentButton.width - units.gu(1)
            anchors.verticalCenter: parent.verticalCenter
            placeholderText: i18n.tr("Add a comment")
            onVisibleChanged: {
                if (visible)
                    forceActiveFocus();
            }
        }

        Button {
            id: addCommentButton
            anchors.verticalCenter: parent.verticalCenter
            color: LomiriColors.green
            text: i18n.tr("Send")
            onClicked: commentPosted(addCommentField.text)
        }
    }
}
