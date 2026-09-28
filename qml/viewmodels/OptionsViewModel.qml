import QtQuick 2.12
import Instagram 1.0

/**
 * OptionsViewModel - ViewModel for OptionsPage
 *
 * Handles account privacy:
 * - Current privacy state
 * - Switching between private and public account
 */
Item {
    id: viewModel
    visible: false

    property bool isPrivate: false

    function loadAccount() {
        instagram.getCurrentUser();
    }

    /**
     * Make the account private or public
     * @param makePrivate - true for private, false for public
     */
    function setPrivate(makePrivate) {
        isPrivate = makePrivate;
        if (makePrivate) {
            instagram.setPrivateAccount();
        } else {
            instagram.setPublicAccount();
        }
    }

    Connections {
        target: instagram
        function onCurrentUserDataReady(answer) {
            handleUserResponse(JSON.parse(answer));
        }
        function onSetProfilePrivate(answer) {
            handleUserResponse(JSON.parse(answer));
        }
        function onSetProfilePublic(answer) {
            handleUserResponse(JSON.parse(answer));
        }
    }

    function handleUserResponse(data) {
        if (data && data.user) {
            isPrivate = data.user.is_private === true;
        }
    }
}
