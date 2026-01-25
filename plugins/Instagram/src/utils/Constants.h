#ifndef INSTAGRAM_CONSTANTS_H
#define INSTAGRAM_CONSTANTS_H

#include <QString>
#include <QByteArray>

namespace IG {
namespace Constants {

// API URLs
QString apiUrl(bool v2 = false);
QString baseUrl();

// Signature
QByteArray sigKey();
QString sigKeyVersion();

// User Agent & Device Info
QByteArray userAgent();
QString deviceManufacturer();
QString deviceModel();
QString deviceName();
QString androidVersion();
QString androidRelease();
QString appVersion();
QString versionCode();

// App identification
QString appId();
QString bloksVersionId();

// Experiments string for API requests
QString experiments();

// API capabilities
QByteArray igCapabilities();

// Locale & Region
QString locale();
QString country();
int countryCode();
int timezoneOffset();

} // namespace Constants
} // namespace IG

#endif // INSTAGRAM_CONSTANTS_H
