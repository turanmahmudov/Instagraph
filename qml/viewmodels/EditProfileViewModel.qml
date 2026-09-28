import QtQuick 2.12
import Instagram 1.0

/**
 * EditProfileViewModel - ViewModel for EditProfilePage
 *
 * Handles profile editing:
 * - Current profile loading
 * - Profile save
 * - Profile picture change and removal
 */
Item {
    id: viewModel
    visible: false

    property var profile: null

    property bool isSaving: false
    property bool isChangingPicture: false

    signal profileSaved
    signal pictureChanged

    function loadProfile() {
        instagram.getCurrentUser();
    }

    /**
     * Save the profile fields
     * @param fields - Object with url, phone, name, biography, email, gender
     */
    function saveProfile(fields) {
        if (isSaving) {
            return;
        }

        isSaving = true;
        instagram.editProfile(fields.url, fields.phone.replace('+', ''), fields.name, fields.biography, fields.email, fields.gender === 1);
    }

    /**
     * Upload a new profile picture
     * @param fileUrl - Local file URL of the picture
     */
    function changePicture(fileUrl) {
        if (isChangingPicture) {
            return;
        }

        isChangingPicture = true;
        instagram.changeProfilePicture(String(fileUrl).replace('file://', ''));
    }

    function removePicture() {
        if (isChangingPicture) {
            return;
        }

        isChangingPicture = true;
        instagram.removeProfilePicture();
    }

    Connections {
        target: instagram
        function onCurrentUserDataReady(answer) {
            var data = JSON.parse(answer);
            if (data.user) {
                profile = data.user;
            }
        }
        function onEditDataReady(answer) {
            if (!isSaving) {
                return;
            }

            isSaving = false;

            var data = JSON.parse(answer);
            if (data.status === "ok") {
                profileSaved();
            }
        }
        function onProfilePictureChanged(answer) {
            handlePictureResponse(JSON.parse(answer));
        }
        function onProfilePictureDeleted(answer) {
            handlePictureResponse(JSON.parse(answer));
        }
        function onError(message) {
            isSaving = false;
            isChangingPicture = false;
        }
    }

    function handlePictureResponse(data) {
        if (!isChangingPicture) {
            return;
        }

        isChangingPicture = false;

        if (data.status === "ok") {
            if (data.user) {
                profile = data.user;
            }
            pictureChanged();
        }
    }
}
