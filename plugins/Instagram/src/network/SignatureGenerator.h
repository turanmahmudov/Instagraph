#ifndef INSTAGRAM_SIGNATUREGENERATOR_H
#define INSTAGRAM_SIGNATUREGENERATOR_H

#include <QByteArray>
#include <QJsonObject>
#include <QString>

namespace IG {

class SignatureGenerator {
public:
    /**
     * Generate signed body for Instagram API
     * @param data The JSON data to sign
     * @param useHmac If true, use actual HMAC signature; if false (default), use
     * "SIGNATURE" literal
     */
    static QString generate(const QJsonObject & data, bool useHmac = false);
    static QByteArray hmacSha256(const QByteArray & data, const QByteArray & key);
};

} // namespace IG

#endif // INSTAGRAM_SIGNATUREGENERATOR_H
