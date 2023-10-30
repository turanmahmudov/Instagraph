import QtQuick 2.12
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3

import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Column {
    width: parent.width
    spacing: units.gu(2)

    property var currentPage: pageLayout.primaryPage
    property var currentUserId: activeUsernameId

    RowLayout {
        spacing: units.gu(1)
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter

        CircleImage {
            width: units.gu(10)
            height: width
            source: userData.profile_pic_url

            Layout.fillWidth: true
            Layout.minimumWidth: units.gu(10)
            Layout.preferredWidth: units.gu(10)
        }

        Column {
            spacing: units.gu(1)

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: units.gu(1)
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter

                Column {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width/3

                    Label {
                        text: userData.media_count
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Label {
                        text: i18n.tr("posts")
                        fontSize: "medium"
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width/3

                    Label {
                        text: Helper.numFormatter(userData.follower_count)
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                pageLayout.pushToNext(currentPage, Qt.resolvedUrl("../ui/UserFollowers.qml"), {userId: currentUserId});
                            }
                        }
                    }
                    Label {
                        text: i18n.tr("followers")
                        fontSize: "medium"
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                pageLayout.pushToNext(currentPage, Qt.resolvedUrl("../ui/UserFollowers.qml"), {userId: currentUserId});
                            }
                        }
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width/3

                    Label {
                        text: Helper.numFormatter(userData.following_count)
                        fontSize: "medium"
                        font.weight: Font.DemiBold
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                pageLayout.pushToNext(currentPage, Qt.resolvedUrl("../ui/UserFollowings.qml"), {userId: currentUserId});
                            }
                        }
                    }
                    Label {
                        text: i18n.tr("following")
                        fontSize: "medium"
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter

                        MouseArea {
                            width: parent.width
                            height: parent.height
                            onClicked: {
                                pageLayout.pushToNext(currentPage, Qt.resolvedUrl("../ui/UserFollowings.qml"), {userId: currentUserId});
                            }
                        }
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        spacing: units.gu(0.5)

        Label {
            text: userData.full_name
            fontSize: "medium"
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }

        Loader {
            width: parent.width
            visible: userData.is_business
            active: visible

            sourceComponent: Label {
                text: userData.category
                width: parent.width
                color: styleApp.common.text2Color
            }
        }

        Label {
            text: userData.biography.split("\n").join("<br>")
            width: parent.width
            wrapMode: Text.WordWrap
            textFormat: Text.RichText
            onLinkActivated: {
                Scripts.linkClick(currentPage, link)
            }
        }

        Loader {
            width: parent.width
            visible: "external_url" in userData && userData.external_url.length > 0
            active: visible

            sourceComponent: Text {
                text: '<a href="'+userData.external_url+'" style="text-decoration:none;color:'+Helper.hexToRgb(styleApp.common.linkColor)+';">'+userData.external_url+'</a>'
                wrapMode: Text.WordWrap
                width: parent.width
                textFormat: Text.RichText
                onLinkActivated: {
                    Scripts.linkClick(currentPage, link)
                }
            }
        }

        Loader {
            width: parent.width
            visible: userData.is_business && (("address_street" in userData && userData.address_street.length > 0) || ("city_name" in userData && userData.city_name.length > 0))
            active: visible

            sourceComponent: Label {
                text: userData.address_street + (userData.city_name && userData.address_street ? (", " + userData.city_name) : (userData.city_name ? userData.city_name : ""))
                width: parent.width
                color: styleApp.common.text2Color
            }
        }
    }
}
