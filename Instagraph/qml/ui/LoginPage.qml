import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import Ubuntu.Components.Styles 1.3

import "../components"

import "../js/Storage.js" as Storage

Page {
    id: loginpage

    header: PageHeader {
        StyleHints {
            dividerColor: "transparent"
        }
        trailingActionBar {
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
                    iconName: "close"
                    text: i18n.tr("Close")
                    onTriggered: {
                        Qt.quit();
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

    Column {
        anchors {
            top: loginpage.header.bottom
            topMargin: units.gu(3)
        }
        width: parent.width
        spacing: units.gu(2)

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Instagraph"
            wrapMode: Text.WordWrap
            font.weight: Font.Bold
            fontSize: "x-large"
            textFormat: Text.RichText
        }

        Item {
            width: parent.width
            height: units.gu(2)
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
            color: UbuntuColors.green
            text: i18n.tr("Log In")
            onTriggered: {
                if(usernameField.text && passwordField.text) {
                    instagram.setUsername(usernameField.text);
                    instagram.setPassword(passwordField.text);
                    instagram.login(true);
                }
            }
        }

        Item {
            width: parent.width
            height: units.gu(2)
        }

        Label {
            id: errorTextLabel
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
        }
    }

    Column {
        width: parent.width
        anchors.bottom: parent.bottom
        height: units.gu(7)

        Rectangle {
            width: parent.width
            height: units.gu(0.08)
            color: UbuntuColors.ash
        }

        Item {
            width: parent.width
            height: parent.height

            Label {
                anchors.centerIn: parent
                text: i18n.tr("Don't have an account? <b>Sign Up</b>.")
                wrapMode: Text.WordWrap
                textFormat: Text.RichText

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("RegisterPage.qml"));
                    }
                }
            }
        }

    }

    Connections{
        target: instagram
        onProfileConnected:{
            console.log('loginned')
            Storage.set("password", passwordField.text);
            Storage.set("username",usernameField.text)
            pageStack.push(tabs);
            anchorToKeyboard = true
            loginPageIsActive = true
        }
        onTwoFactorRequired:{
            Storage.set("password", passwordField.text);
            Storage.set("username",usernameField.text)
            pageStack.push(Qt.resolvedUrl("2FactorLoginPage.qml"), {answer: answer});
            anchorToKeyboard = true
            loginPageIsActive = false
        }
    }

    Connections{
        target: instagram
        onProfileConnectedFail:{
            console.log('login failed')
        }
        onError:{
            console.log(message);
            errorTextLabel.text = message;
        }
    }
}
