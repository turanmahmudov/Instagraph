import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.LocalStorage 2.12
import QtGraphicalEffects 1.0
import Lomiri.Components.Styles 1.3

import "../components"

import "../js/Storage.js" as Storage
import "../js/Helper.js" as Helper
import "../js/Scripts.js" as Scripts

PageItem {
    id: registerpage

    header: PageHeaderItem {}

    Component.onCompleted: {
        anchorToKeyboard = false
    }

    Column {
        anchors {
            top: registerpage.header.bottom
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
            source: Qt.resolvedUrl("../../instagraph_title.png")
        }

        Item {
            width: parent.width
            height: units.gu(1)
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
        }

        TextField {
            id: usernameField
            width: parent.width*0.8
            height: units.gu(5)
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: i18n.tr("Username")
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
            color: LomiriColors.ash
        }

        Item {
            width: parent.width
            height: parent.height

            Label {
                anchors.centerIn: parent
                text: i18n.tr("Already have an account? <b>Log In</b>.")
                wrapMode: Text.WordWrap
                textFormat: Text.RichText

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageLayout.removePages(pageLayout.primaryPage)
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
            if (data.status === "ok") {
                if (data.account_created === true) {
                    console.log('REGISTER COMPLETED')

                    console.log('TODO: GO TO LOGIN AND ASK TO LOGIN')
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
