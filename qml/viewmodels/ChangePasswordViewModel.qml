import QtQuick 2.12
import Instagram 1.0

import "../js/Storage.js" as Storage

/**
 * ChangePasswordViewModel - ViewModel for ChangePasswordPage
 *
 * Handles password change:
 * - Validation of the new password
 * - Password change request
 * - Saved login password update
 */
Item {
    id: viewModel
    visible: false

    property bool isSaving: false
    property string errorMessage: ""

    property string pendingPassword: ""

    signal passwordChanged

    /**
     * Change the account password
     * @param currentPassword - Current password
     * @param newPassword - New password
     * @param newPasswordAgain - New password, second entry
     */
    function changePassword(currentPassword, newPassword, newPasswordAgain) {
        if (isSaving) {
            return;
        }

        if (newPassword !== newPasswordAgain) {
            errorMessage = i18n.tr("The new passwords do not match.");
            return;
        }

        errorMessage = "";
        isSaving = true;
        pendingPassword = newPassword;

        instagram.changePassword(currentPassword, newPassword);
    }

    Connections {
        target: instagram
        function onChangePasswordDataReady(answer) {
            if (!isSaving) {
                return;
            }

            isSaving = false;

            var data = JSON.parse(answer);
            if (data.status === "ok") {
                instagram.setPassword(pendingPassword);
                Storage.updatePassword(activeUsername, pendingPassword);
                pendingPassword = "";
                passwordChanged();
            } else {
                errorMessage = data.message || i18n.tr("Could not change the password.");
            }
        }
        function onError(message) {
            if (isSaving) {
                isSaving = false;
                pendingPassword = "";
                errorMessage = message;
            }
        }
    }
}
