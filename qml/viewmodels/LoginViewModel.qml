import QtQuick 2.12
import Instagram 1.0

/**
 * LoginViewModel - ViewModel for LoginPage and 2FactorLoginPage
 *
 * Handles login logic:
 * - Username and password login
 * - Two-factor code confirmation
 * - Login state and error message
 */
Item {
    id: viewModel
    visible: false

    property bool isLoggingIn: false
    property string errorMessage: ""

    /**
     * Log in with a new account
     * @param username - Account user name
     * @param password - Account password
     */
    function login(username, password) {
        if (!username || !password || isLoggingIn) {
            return;
        }

        errorMessage = "";
        isLoggingIn = true;

        tmpUsername = username;
        tmpPassword = password;

        instagram.setUsername(username);
        instagram.setPassword(password);
        instagram.login(true);
    }

    /**
     * Confirm the two-factor code
     * @param code - Code from SMS or the authentication app
     * @param twoFactorInfo - two_factor_info object from the login response
     */
    function confirmTwoFactor(code, twoFactorInfo) {
        if (!code || !twoFactorInfo || isLoggingIn) {
            return;
        }

        errorMessage = "";
        isLoggingIn = true;

        var method = twoFactorInfo.totp_two_factor_on === true ? "3" : "1";
        instagram.confirm2Factor(code, twoFactorInfo.two_factor_identifier, method);
    }

    Connections {
        target: instagram
        function onProfileConnected(answer) {
            isLoggingIn = false;
        }
        function onTwoFactorRequired(answer) {
            isLoggingIn = false;
        }
        function onError(message) {
            if (isLoggingIn) {
                isLoggingIn = false;
                errorMessage = message;
            }
        }
    }
}
