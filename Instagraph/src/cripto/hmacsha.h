#ifndef HMACSHA_H
#define HMACSHA_H

#include <QObject>
#include <QCryptographicHash>

class HmacSHA : public QObject
{
    Q_OBJECT
public:
    explicit HmacSHA(QObject *parent = 0);
    static QByteArray hash(QByteArray stringToSign, QByteArray secretKey);
};

#endif // HMACSHA_H
