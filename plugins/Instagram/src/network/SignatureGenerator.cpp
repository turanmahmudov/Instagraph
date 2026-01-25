#include "SignatureGenerator.h"
#include "../utils/Constants.h"
#include <QJsonDocument>
#include <QMessageAuthenticationCode>
#include <QUrl>

namespace IG {

QString SignatureGenerator::generate(const QJsonObject& data, bool useHmac) {
    QJsonDocument doc(data);
    QString dataString(doc.toJson(QJsonDocument::Compact));

    // Fix for crop_center format expected by Instagram
    dataString.replace("\"crop_center\":[0,0]", "\"crop_center\":[0.0,-0.0]");

    if (useHmac) {
        // Old style: actual HMAC signature (rarely needed now)
        QByteArray hash = hmacSha256(dataString.toUtf8(), Constants::sigKey());
        return QString("ig_sig_key_version=%1&signed_body=%2.%3")
            .arg(Constants::sigKeyVersion())
            .arg(QString(hash.toHex()))
            .arg(dataString);
    } else {
        // Modern style: literal "SIGNATURE" string (used by instagrapi)
        QString encodedData = QString::fromUtf8(QUrl::toPercentEncoding(dataString));
        return QString("signed_body=SIGNATURE.%1").arg(encodedData);
    }
}

QByteArray SignatureGenerator::hmacSha256(const QByteArray& data, const QByteArray& key) {
    return QMessageAuthenticationCode::hash(data, key, QCryptographicHash::Sha256);
}

} // namespace IG
