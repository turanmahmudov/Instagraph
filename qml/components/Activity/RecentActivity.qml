import QtQuick 2.12
import Lomiri.Components 1.3

import ".."
import "../Constants"
import "../Feed"

import "../../js/Scripts.js" as Scripts
import "../../js/Helper.js" as Helper

ListItem {
    height: layout.height
    divider.visible: false

    SlotsLayout {
        id: layout
        anchors.centerIn: parent
        padding.leading: 0
        padding.trailing: 0
        padding.top: units.gu(1)
        padding.bottom: units.gu(1)

        mainSlot: Column {
            width: parent.width

            Loader {
                visible: header !== ""
                active: visible
                width: parent.width
                height: units.gu(4)

                sourceComponent: Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: i18n.tr(header)
                    width: parent.width
                    font.weight: Font.DemiBold
                    color: styleApp.common.textColor
                }
            }

            Row {
                id: labelRecent
                spacing: units.gu(1)
                width: parent.width - (story_type === 3 ? followButton.width : feed_image.width)

                CircleImage {
                    width: units.gu(5)
                    height: width
                    source: story_type === 13 ? "image://theme/info" : (typeof profile_image !== 'undefined' ? profile_image : "../../images/not_found_user.jpg")

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (typeof profile_id !== 'undefined')
                                pageLayout.pushToCurrent(pageLayout.primaryPage, PagesConstants.user, {
                                    usernameId: profile_id
                                });
                        }
                    }
                }

                Column {
                    width: parent.width - units.gu(6)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: Helper.formatString(Helper.formatRichTextUsers(activity_text))
                        wrapMode: Text.WordWrap
                        width: parent.width
                        textFormat: Text.RichText
                        color: styleApp.common.textColor
                        font.weight: story_type == 13 ? Font.DemiBold : Font.Normal
                        onLinkActivated: {
                            Scripts.linkClick(activitypage, link, story_type === 1 ? media.id : 0);
                        }
                    }

                    Label {
                        text: timestamp ? Helper.milisecondsToString(timestamp) : ''
                        fontSize: "small"
                        color: styleApp.common.text2Color
                        font.weight: Font.Light
                        font.capitalization: Font.AllLowercase
                    }
                }
            }
        }

        Loader {
            id: followButton
            visible: story_type == 3 && typeof inline_follow !== 'undefined'
            active: visible
            width: visible ? item.width : 0

            anchors.verticalCenter: parent.verticalCenter
            SlotsLayout.position: SlotsLayout.Trailing
            SlotsLayout.overrideVerticalPositioning: true

            sourceComponent: Item {
                height: units.gu(3.5)
            }
        }

        FeedImage {
            id: feed_image
            width: (story_type === 1 || story_type === 14) ? units.gu(5) : 0
            height: width
            visible: width
            source: visible ? media.image : ""

            anchors.verticalCenter: parent.verticalCenter
            SlotsLayout.position: SlotsLayout.Trailing
            SlotsLayout.overrideVerticalPositioning: true

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (feed_image.visible) {
                        pageLayout.pushToNext(pageLayout.primaryPage, PagesConstants.photo, {
                            photoId: media.id
                        });
                    }
                }
            }
        }
    }
}
