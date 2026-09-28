import QtQuick 2.12
import Instagram 1.0

/**
 * SessionViewModel - ViewModel for the app session in Main
 *
 * Handles the account session:
 * - Login with a stored account, logout
 * - Profile connected and two-factor results
 * - FBNS push registration
 */
Item {
    id: viewModel
    visible: false

    property bool mqttConnected: false

    signal profileConnected(var usernameId)
    signal twoFactorRequired(var answer)

    function login(force, username, password) {
        instagram.setUsername(username);
        instagram.setPassword(password);

        instagram.login(force === true, username, password, true);
    }

    function logout() {
        instagram.logout();
    }

    function connectPush(usernameId) {
        if (mqttConnected) {
            return;
        }

        var phoneId = instagram.getPhoneId();
        if (!phoneId || phoneId === "") {
            console.log("MQTT: no phoneId available");
            return;
        }

        mqtt.connectToMqtt(usernameId, phoneId);
        mqttConnected = true;
    }

    Connections {
        target: instagram
        function onProfileConnected(answer) {
            console.log('PROFILE CONNECTED');
            profileConnected(instagram.getUsernameId());
        }
        function onTwoFactorRequired(answer) {
            console.log('2FACTOR REQUIRED');
            twoFactorRequired(answer);
        }
    }

    Connections {
        target: mqtt
        function onFbnsTokenReceived(token) {
            instagram.registerPush(token);
        }
    }
}
