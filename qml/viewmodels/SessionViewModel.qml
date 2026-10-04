import QtQuick 2.12
import Instagram 1.0

/**
 * SessionViewModel - ViewModel for the app session in Main
 *
 * Handles the account session:
 * - Login with a stored account, logout
 * - Profile connected, two-factor and failed login results
 * - FBNS push registration
 */
Item {
    id: viewModel
    visible: false

    property bool mqttConnected: false
    property bool isLoggingIn: false

    signal profileConnected(var usernameId)
    signal twoFactorRequired(var answer)
    signal loginFailed(string message)

    function login(force, username, password) {
        isLoggingIn = true;
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
            isLoggingIn = false;
            profileConnected(instagram.getUsernameId());
        }
        function onTwoFactorRequired(answer) {
            console.log('2FACTOR REQUIRED');
            isLoggingIn = false;
            twoFactorRequired(answer);
        }
        function onError(message) {
            if (isLoggingIn) {
                isLoggingIn = false;
                loginFailed(message);
            }
        }
    }

    Connections {
        target: mqtt
        function onFbnsTokenReceived(token) {
            instagram.registerPush(token);
        }
    }
}
