#ifndef CONSTANTS_H
#define CONSTANTS_H

#include <QString>
#include <QByteArray>

namespace Constants {
    QString experiments();
    QString sigKeyVersion();
    QString apiUrl(bool v2 = false);
    QString urlWithoutApi();
    QByteArray userAgent();
    QByteArray isSigKey();
}

#endif // CONSTANTS_H
