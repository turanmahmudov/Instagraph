import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components.Styles 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

Page {
    id: registerpage

    header: PageHeader {
        StyleHints {
            backgroundColor: "transparent"
            dividerColor: "transparent"
        }
        leadingActionBar {
            numberOfSlots: 1
            delegate: AbstractButton {
                id: button
                action: modelData
                height: parent.height
                width: height
                Icon {
                    anchors.centerIn: parent
                    width: units.gu(2)
                    height: width
                    name: iconName
                    color: theme.palette.normal.baseText
                }
            }
            actions: [
                Action {
                    iconName: "back"
                    text: i18n.tr("Back")
                    onTriggered: {
                        pageStack.pop()
                    }
                }
            ]
        }
    }

    Component.onCompleted: {
        anchorToKeyboard = false
    }

    BouncingProgressBar {
        id: bouncingProgress
        z: 10
        anchors.top: parent.top
        visible: instagram.busy
    }

    Rectangle {
        anchors.fill: parent

        LinearGradient {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(parent.width, 0)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#7451A9" }
                GradientStop { position: 1.0; color: "#2270C0" }
            }
        }
    }

    Column {
        anchors {
            top: registerpage.header.bottom
            topMargin: units.gu(3)
        }
        width: parent.width
        spacing: units.gu(2)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Instagraph"
            wrapMode: Text.WordWrap
            font.weight: Font.Bold
            fontSize: "large"
            textFormat: Text.RichText
            color: theme.palette.highlighted.basetext
        }

        Item {
            width: parent.width
            height: units.gu(2)
        }

        TextField {
            id: emailField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: i18n.tr("Email")
            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus()
                }
            }
            StyleHints {
                backgroundColor: "#EAE9E7"
                borderColor: "transparent"
            }
        }

        TextField {
            id: usernameField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: i18n.tr("Username")
            StyleHints {
                backgroundColor: "#EAE9E7"
                borderColor: "transparent"
            }
        }

        TextField {
            id: passwordField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            echoMode: TextInput.Password
            placeholderText: i18n.tr("Password")
            StyleHints {
                backgroundColor: "#EAE9E7"
                borderColor: "transparent"
            }
        }

        Button {
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#EAE9E7"
            text: i18n.tr("Sign Up")
            onTriggered: {
                if(usernameField.text && passwordField.text && emailField.text) {
                    instagram.createAccount(usernameField.text, passwordField.text, emailField.text);
                }
            }
        }
    }

    Column {
        width: parent.width
        anchors.bottom: parent.bottom
        height: units.gu(7)

        Rectangle {
            width: parent.width
            height: units.gu(0.08)
            color: Qt.rgba(234,233,231,0.2)
        }

        Item {
            width: parent.width
            height: parent.height

            Label {
                anchors.centerIn: parent
                text: i18n.tr("Already have an account? <b>Log In</b>.")
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                color: "#EAE9E7"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.pop()
                    }
                }
            }
        }

    }

    Connections{
        target: instagram
        onCreateAccountDataReady: {
            console.log(answer);
            var data = JSON.parse(answer);
            if (data.status == "ok") {
                if (data.account_created == true) {
                    Storage.set("password", passwordField.text);
                    Storage.set("username", usernameField.text);

                    Scripts.registered()

                    anchorToKeyboard = true
                } else {
                    if (data.errors && data.errors.length > 0) {

                    }
                }
            } else {
                // error
            }
        }
    }
}
