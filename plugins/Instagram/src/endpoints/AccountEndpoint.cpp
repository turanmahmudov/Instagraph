#include "AccountEndpoint.h"
#include "../core/ApiClient.h"
#include "../core/Request.h"
#include "../core/Response.h"
#include "../utils/Constants.h"
#include <QUuid>

namespace IG {

AccountEndpoint::AccountEndpoint(ApiClient * client, QObject * parent)
    : QObject(parent), m_client(client) {}

void AccountEndpoint::fetchHeaders() {
    auto request =
        RequestBuilder::get("si/fetch_headers/").queryParam("challenge_type", "signup").build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit headersReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::preLoginFlow(const QString & uuid, const QString & /* phoneId */,
                                   const QString & /* deviceId */) {
    // Pre-login sync based on instagrapi's pre_login_flow()
    // This calls launcher/sync endpoint before login
    auto request = RequestBuilder::post("launcher/sync/")
                       .param("id", uuid)
                       .param("server_config_retrieval", "1")
                       .build();

    m_client->execute(request, [this](const Response & response) {
        // Pre-login can fail but we still emit the signal to continue login flow
        emit preLoginFlowReady(response.toVariant());
    });
}

void AccountEndpoint::login(const QString & username, const QString & encPassword,
                            const QString & uuid, const QString & deviceId, const QString & phoneId,
                            const QString & advertisingId, const QString & jazoest) {
    // Modern login parameters based on instagrapi
    // Note: No _csrftoken for login request!
    // The request IS signed with SIGNATURE literal (not actual HMAC)
    auto request =
        RequestBuilder::post("accounts/login/")
            .param("jazoest", jazoest)
            .param("country_codes", "[{\"country_code\":\"1\",\"source\":[\"default\"]}]")
            .param("phone_id", phoneId)
            .param("enc_password", encPassword)
            .param("username", username)
            .param("adid", advertisingId)
            .param("guid", uuid)
            .param("device_id", deviceId)
            .param("google_tokens", "[]")
            .param("login_attempt_count", "0")
            .build();

    m_client->execute(request, [this](const Response & response) {
        // Check for 2FA response - Instagram returns HTTP 400 with
        // two_factor_required but we still need to process this as a valid response
        if (response.ok()) {
            emit loginReady(response.toVariant());
        } else if (response.json().contains("two_factor_required") &&
                   response.json()["two_factor_required"].toBool()) {
            // 2FA required - still emit loginReady so it gets processed
            emit loginReady(response.toVariant());
        } else if (response.json().contains("challenge") ||
                   response.json()["message"].toString() == "challenge_required") {
            // Challenge required - still emit loginReady so it gets processed
            emit loginReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::confirm2Factor(const QString & code, const QString & identifier,
                                     const QString & method, const QString & username,
                                     const QString & phoneId, const QString & uuid,
                                     const QString & deviceId, const QString & csrfToken) {
    // Generate waterfall_id for this request
    QString waterfallId = QUuid::createUuid().toString();
    waterfallId = waterfallId.mid(1, waterfallId.length() - 2);

    // Modern 2FA parameters based on instagrapi
    // Note: No password needed - uses two_factor_identifier from login response
    auto request = RequestBuilder::post("accounts/two_factor_login/")
                       .param("verification_code", code)
                       .param("phone_id", phoneId)
                       .param("_csrftoken", csrfToken)
                       .param("two_factor_identifier", identifier)
                       .param("username", username)
                       .param("trust_this_device", "0")
                       .param("guid", uuid)
                       .param("device_id", deviceId)
                       .param("waterfall_id", waterfallId)
                       .param("verification_method", method)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit twoFactorLoginReady(response.toVariant());
        } else {
            // Check if this is actually a success with status=fail but logged_in_user
            // present
            if (response.json().contains("logged_in_user")) {
                emit twoFactorLoginReady(response.toVariant());
            } else {
                emit error(response.errorMessage());
            }
        }
    });
}

void AccountEndpoint::logout(const QString & uuid, const QString & deviceId,
                             const QString & csrfToken) {
    auto request = RequestBuilder::get("accounts/logout/")
                       .queryParam("_csrftoken", csrfToken)
                       .queryParam("guid", uuid)
                       .queryParam("device_id", deviceId)
                       .queryParam("_uuid", uuid)
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit logoutReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::setPrivateAccount() {
    auto request = RequestBuilder::post("accounts/set_private/").authenticated().build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit profilePrivateReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::setPublicAccount() {
    auto request = RequestBuilder::post("accounts/set_public/").authenticated().build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit profilePublicReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::removeProfilePicture() {
    auto request = RequestBuilder::post("accounts/remove_profile_picture/").authenticated().build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit profilePictureRemoved(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::getCurrentUser() {
    auto request = RequestBuilder::get("accounts/current_user/").queryParam("edit", "true").build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit currentUserReady(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::editProfile(const QString & url, const QString & phone,
                                  const QString & firstName, const QString & biography,
                                  const QString & email, bool gender, const QString & username) {
    QString genderString = gender ? "1" : "0";

    auto request = RequestBuilder::post("accounts/edit_profile/")
                       .queryParam("edit", "true")
                       .param("external_url", url)
                       .param("phone_number", phone)
                       .param("username", username)
                       .param("first_name", firstName)
                       .param("biography", biography)
                       .param("email", email)
                       .param("gender", genderString)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit profileEdited(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::changePassword(const QString & encOldPassword,
                                     const QString & encNewPassword) {
    auto request = RequestBuilder::post("accounts/change_password/")
                       .param("enc_old_password", encOldPassword)
                       .param("enc_new_password1", encNewPassword)
                       .param("enc_new_password2", encNewPassword)
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit passwordChanged(response.toVariant());
        } else {
            emit error(response.errorMessage());
        }
    });
}

void AccountEndpoint::syncFeatures(const QString & userId, const QString & /* password */) {
    // Post-login qe/sync - does NOT send password, uses authenticated params
    // Requests are signed by default, so no need to call signed_()
    auto request = RequestBuilder::post("qe/sync/")
                       .param("id", userId)
                       .param("server_config_retrieval", "1")
                       .param("experiments", Constants::experiments())
                       .authenticated()
                       .build();

    m_client->execute(request, [this](const Response & response) {
        if (response.ok()) {
            emit featuresSynced(response.toVariant());
        }
        // qe/sync errors are not critical, silently ignore them
    });
}

} // namespace IG
