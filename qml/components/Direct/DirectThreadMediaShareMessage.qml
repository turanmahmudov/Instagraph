import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import ".."
import "../Constants"
import "../Feed"

import "../../js/Helper.js" as Helper
import "../../js/Scripts.js" as Scripts

Column {
    property bool isOutgoing: false
    property var itemMaxWidth

    spacing: units.gu(0.4)

    Rectangle {
        width: itemMaxWidth
        height: mediShareColumn.height + units.gu(2.5)
        color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
        radius: units.gu(2)
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

        Column {
            id: mediShareColumn
            width: parent.width
            spacing: units.gu(1)

            Item {
                width: parent.width
                height: units.gu(0.1)
            }

            Row {
                x: units.gu(1)
                width: parent.width - units.gu(2)
                spacing: units.gu(1)
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                CircleImage {
                    width: units.gu(4)
                    height: width
                    source: typeof media_share.user != 'undefined' && typeof media_share.user.profile_pic_url != 'undefined' ? media_share.user.profile_pic_url : "../../images/not_found_user.jpg"

                    MouseArea {
                        anchors {
                            fill: parent
                        }
                        onClicked: {
                            pageLayout.pushToCurrent(directthreadpage, PagesConstants.user, {
                                usernameId: media_share.user.pk
                            });
                        }
                    }
                }

                Column {
                    spacing: units.gu(0.2)
                    width: parent.width - units.gu(4)
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    Label {
                        text: typeof media_share.user != 'undefined' && typeof media_share.user.username != 'undefined' ? media_share.user.username : ''
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap

                        MouseArea {
                            anchors {
                                fill: parent
                            }
                            onClicked: {
                                pageLayout.pushToCurrent(directthreadpage, PagesConstants.user, {
                                    usernameId: media_share.user.pk
                                });
                            }
                        }
                    }
                }
            }

            FeedImage {
                id: feed_image
                width: parent.width
                height: width / bestImage.width * bestImage.height
                source: bestImage.url
                smooth: true
                clip: true

                property var bestImage: typeof media_share.carousel_media !== 'undefined' && media_share.carousel_media.length > 0 ? Helper.getBestImage(media_share.carousel_media[0].image_versions2.candidates, parent.width) : Helper.getBestImage(media_share.image_versions2.candidates, parent.width)

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.pushToNext(directthreadpage, PagesConstants.photo, {
                            photoId: media_share.id
                        });
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: typeof media_share.caption !== 'undefined' ? (typeof media_share.caption.text !== 'undefined' ? true : false) : false
                text: visible ? (Helper.formatUser(media_share.caption.user.username) + ' ' + media_share.caption.text.substring(0, 45) + '...') : ""
                wrapMode: Text.WordWrap
                width: parent.width - units.gu(2)
                textFormat: Text.RichText
                color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
                onLinkActivated: {
                    Scripts.linkClick(directthreadpage, link);
                }
            }
        }

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right;
            }
        }
    }

    Rectangle {
        visible: typeof media_share.text != 'undefined'
        width: typeof media_share.text != 'undefined' ? myMediaShareText.width + units.gu(3) : 0
        height: typeof media_share.text != 'undefined' ? myMediaShareText.height + units.gu(2.5) : 0
        color: isOutgoing ? styleApp.directInbox.outgoingMessageBackgroundColor : styleApp.directInbox.incomingMessageBackgroundColor
        radius: units.gu(2)
        border.width: units.gu(0.1)
        border.color: Qt.lighter(LomiriColors.lightGrey, 1.2)

        Label {
            id: myMediaShareText
            wrapMode: Text.WordWrap
            width: Math.min(myMediaShareText.implicitWidth, itemMaxWidth)
            anchors.centerIn: parent
            text: typeof media_share.text != 'undefined' ? media_share.text : ''
            color: isOutgoing ? styleApp.directInbox.outgoingMessageTextColor : styleApp.directInbox.incomingMessageTextColor
        }

        Component.onCompleted: {
            if (isOutgoing) {
                anchors.right = parent.right;
            }
        }
    }
}
