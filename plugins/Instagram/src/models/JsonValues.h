#ifndef INSTAGRAM_JSONVALUES_H
#define INSTAGRAM_JSONVALUES_H

#include <QJsonArray>
#include <QJsonObject>
#include <QJsonValue>
#include <QString>
#include <QVariant>

namespace JsonValues {

bool isTruthy(const QJsonValue & value);
bool isTrue(const QJsonValue & value);
QJsonValue pickTruthy(const QJsonValue & value, const QJsonValue & fallback);
QString convertToString(const QJsonValue & value);
double convertToNumber(const QJsonValue & value);

// Same output as Number.prototype.toLocaleString() in a Qt 5 WorkerScript: 6 significant
// digits, so 1234567 becomes "1.23457e+06"
QString formatLocaleNumber(const QJsonValue & value);

QVariant convertWithoutNulls(const QJsonValue & value);
QVariantMap convertObjectWithoutNulls(const QJsonObject & object);

} // namespace JsonValues

#endif // INSTAGRAM_JSONVALUES_H
