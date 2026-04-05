#include "Constants.h"

namespace IG {
namespace Constants {

QString apiUrl(bool v2) {
    if (v2) {
        return QStringLiteral("https://i.instagram.com/api/v2/");
    }
    return QStringLiteral("https://i.instagram.com/api/v1/");
}

QString baseUrl() {
    return QStringLiteral("https://i.instagram.com/");
}

QByteArray sigKey() {
    // This key is used for HMAC-SHA256 signing
    return "9193488027538fd3450b83b7d05286d4ca9599a0f7eeed90d8c85925698a05dc";
}

QString sigKeyVersion() {
    return QStringLiteral("4");
}

// Updated to latest Instagram 367.0.0.27.101 with Samsung Galaxy S25 Ultra
QByteArray userAgent() {
    return "Instagram 367.0.0.27.101 Android (35/15.0; 640dpi; 1440x3088; "
           "samsung; SM-S938U; s25u; qcom; en_US; 658859659)";
}

QString deviceManufacturer() {
    return QStringLiteral("samsung");
}

QString deviceModel() {
    return QStringLiteral("SM-S938U");
}

QString deviceName() {
    return QStringLiteral("s25u");
}

QString androidVersion() {
    return QStringLiteral("35");
}

QString androidRelease() {
    return QStringLiteral("15.0");
}

QString appVersion() {
    return QStringLiteral("367.0.0.27.101");
}

QString versionCode() {
    return QStringLiteral("658859659");
}

QString appId() {
    return QStringLiteral("567067343352427");
}

QString bloksVersionId() {
    // Updated bloks version for 2026
    return QStringLiteral("d5b6cc92dbdfd2c9d2c039ef5191b1287b547b2f0e0c8b5b6e8e6c8e24f8db07");
}

QByteArray igCapabilities() {
    // Updated capabilities from instagrapi
    return "3brTvx0=";
}

QString experiments() {
    return QStringLiteral("ig_android_reg_nux_headers_cleanup_universe,"
                          "ig_android_device_detection_info_upload,"
                          "ig_android_nux_add_email_device,"
                          "ig_android_gmail_oauth_in_reg,"
                          "ig_android_device_info_foreground_reporting,"
                          "ig_android_device_verification_fb_signup,"
                          "ig_android_direct_main_tab_universe_v2,"
                          "ig_android_passwordless_account_password_creation_universe,"
                          "ig_android_direct_add_direct_to_android_native_photo_share_sheet,"
                          "ig_growth_android_profile_pic_prefill_with_fb_pic_2,"
                          "ig_account_identity_logged_out_signals_global_holdout_universe,"
                          "ig_android_quickcapture_keep_screen_on,"
                          "ig_android_device_based_country_verification,"
                          "ig_android_login_identifier_fuzzy_match,"
                          "ig_android_reg_modularization_universe,"
                          "ig_android_security_intent_switchoff,"
                          "ig_android_device_verification_separate_endpoint,"
                          "ig_android_suma_landing_page,"
                          "ig_android_sim_info_upload,"
                          "ig_android_smartlock_hints_universe,"
                          "ig_android_fb_account_linking_sampling_freq_universe,"
                          "ig_android_retry_create_account_universe,"
                          "ig_android_caption_typeahead_fix_on_o_universe");
}

QString locale() {
    return QStringLiteral("en_US");
}

QString country() {
    return QStringLiteral("US");
}

int countryCode() {
    return 1; // USA
}

int timezoneOffset() {
    return -14400; // GMT-4 (New York) in seconds
}

} // namespace Constants
} // namespace IG
