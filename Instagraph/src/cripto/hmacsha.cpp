#include "hmacsha.h"

HmacSHA::HmacSHA(QObject *parent) : QObject(parent){

}

QByteArray HmacSHA::hash(QByteArray stringToSign, QByteArray secretKey){

    QCryptographicHash::Algorithm alg = QCryptographicHash::Sha256;

    int blockSize = 64; // HMAC-SHA-1 & SHA-256 Blocksize

    //Hmac, as defined inf RFC 2104 requires a certain length of key (blockSize) and these next two if clauses make sure that it is like so.
    if (secretKey.length() > blockSize) {
        secretKey = QCryptographicHash::hash(secretKey, alg);
    }

    //If the length is too short, the message is padded with 0x00 as stated in the spec
    if (secretKey.length() < blockSize) {
        int padding = blockSize - secretKey.length();
        secretKey.append(QByteArray(padding, char(0x00)));
    }
    QByteArray innerPadding(blockSize, char(0x36));
    QByteArray outerPadding(blockSize, char(0x5c));

    for (int i = 0; i < secretKey.length(); i++) {
        innerPadding[i] = innerPadding[i] ^ secretKey.at(i);
        outerPadding[i] = outerPadding[i] ^ secretKey.at(i);
    }

    QByteArray total = outerPadding;
    QByteArray part = innerPadding;
    part.append(stringToSign);
    total.append(QCryptographicHash::hash(part, alg));
    QByteArray hashed = QCryptographicHash::hash(total, alg);

    return hashed;
}
