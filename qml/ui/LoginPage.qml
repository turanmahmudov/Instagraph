// Qt imports
import QtQuick 2.12
import QtQuick.LocalStorage 2.12

// Lomiri imports
import Lomiri.Components 1.3

// JavaScript imports
import "../js/Storage.js" as Storage

// Component imports
import "../components"
import "../components/Constants"
import "../components/Page"
import "../components/User"
import "../components/Feed"
import "../components/Media"
import "../components/Camera"
import "../components/Actions"

PageItem {
    id: loginpage

    header: PageHeaderItem {
        noBackAction: true
        trailingActions: [
            Action {
                text: i18n.tr("Close")
                iconName: IconsConstants.bookmark
                onTriggered: {
                    Qt.quit();
                }
            }
        ]
    }

    Component.onCompleted: {
        anchorToKeyboard = false

        loading.visible = false
    }

    Column {
        anchors {
            top: loginpage.header.bottom
            topMargin: units.gu(3)
        }
        width: parent.width
        spacing: units.gu(2)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: units.gu(15)
            height: units.gu(5)
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(width, height)
            source: "qrc:/assets/instagraph_title.png"
        }

        Item {
            width: parent.width
            height: units.gu(1)
        }

        TextField {
            id: usernameField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: i18n.tr("Username")
            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus()
                }
            }
        }

        TextField {
            id: passwordField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            echoMode: TextInput.Password
            placeholderText: i18n.tr("Password")
        }

        Button {
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            color: LomiriColors.blue
            text: i18n.tr("Log In")
            onTriggered: {
                if(usernameField.text && passwordField.text) {
                    tmpUsername = usernameField.text
                    tmpPassword = passwordField.text

                    instagram.setUsername(tmpUsername);
                    instagram.setPassword(tmpPassword);

                    instagram.login(true);
                }
            }
        }

        Column {
            property bool savedAccounts: Storage.getAccounts().length > 0

            width: parent.width
            height: savedAccounts ? units.gu(10) : 0
            visible: savedAccounts
            spacing: units.gu(1)

            Item {
                width: parent.width
                height: units.gu(4)

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: units.gu(0.1)
                    color: LomiriColors.ash
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: orText.width + units.gu(3)
                    height: orText.height
                    color: styleApp.mainView.backgroundColor

                    Label {
                        id: orText
                        anchors.centerIn: parent
                        text: i18n.tr("OR")
                        font.weight: Font.DemiBold

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageLayout.addPageToCurrentColumn(pageLayout.primaryPage, PagesConstants.register)
                            }
                        }
                    }
                }
            }

            Button {
                width: parent.width*0.8
                height: units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
                color: LomiriColors.blue
                text: i18n.tr("Log In with Saved Accounts")
                onTriggered: {
                    bottomEdge.commit()
                }
            }
        }

        Label {
            id: errorTextLabel
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
        }
    }

    Column {
        width: parent.width
        height: units.gu(7)
        anchors.bottom: parent.bottom

        Rectangle {
            width: parent.width
            height: units.gu(0.08)
            color: LomiriColors.ash
        }

        Item {
            width: parent.width
            height: parent.height

            Label {
                anchors.centerIn: parent
                width: parent.width
                text: i18n.tr("Don't have an account? <b>Sign Up</b>.")
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.addPageToCurrentColumn(pageLayout.primaryPage, PagesConstants.register)
                    }
                }
            }
        }
    }

    BottomEdge {
        id: bottomEdge
        height: parent.height/2
        hint.visible: false
        preloadContent: true
        contentComponent: MultipleAccountsSwitcher {
            width: bottomEdge.width
            height: bottomEdge.height
        }
        onCommitCompleted: {
            bottomEdge.contentItem.init()
        }
    }

    Connections{
        target: instagram
        onProfileConnected: {
        }
        onTwoFactorRequired: {
        }
        onProfileConnectedFail: {
        }
        onError:{
            console.log(message);
            errorTextLabel.text = message;
        }
        onChallengeRequired: {
            var challengeUrl = answer["url"]
        }
    }
}
