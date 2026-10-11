#include "JsonValues.h"

#include <QLocale>
#include <cmath>
#include <limits>

namespace JsonValues {

bool isTruthy(const QJsonValue & value) {
    switch (value.type()) {
    case QJsonValue::Bool:
        return value.toBool();
    case QJsonValue::Double: {
        double number = value.toDouble();
        return number != 0 && !std::isnan(number);
    }
    case QJsonValue::String:
        return !value.toString().isEmpty();
    case QJsonValue::Array:
    case QJsonValue::Object:
        return true;
    default:
        return false;
    }
}

bool isTrue(const QJsonValue & value) {
    return value.isBool() && value.toBool();
}

QJsonValue pickTruthy(const QJsonValue & value, const QJsonValue & fallback) {
    return isTruthy(value) ? value : fallback;
}

QString convertToString(const QJsonValue & value) {
    switch (value.type()) {
    case QJsonValue::String:
        return value.toString();
    case QJsonValue::Bool:
        return value.toBool() ? QStringLiteral("true") : QStringLiteral("false");
    case QJsonValue::Double: {
        double number = value.toDouble();
        if (number == std::floor(number) && std::fabs(number) < 1e21) {
            return QString::number(number, 'f', 0);
        }
        return QString::number(number, 'g', QLocale::FloatingPointShortest);
    }
    case QJsonValue::Null:
        return QStringLiteral("null");
    case QJsonValue::Undefined:
        return QStringLiteral("undefined");
    default:
        return QStringLiteral("[object Object]");
    }
}

double convertToNumber(const QJsonValue & value) {
    switch (value.type()) {
    case QJsonValue::Double:
        return value.toDouble();
    case QJsonValue::Bool:
        return value.toBool() ? 1 : 0;
    case QJsonValue::Null:
        return 0;
    case QJsonValue::String: {
        const QString text = value.toString().trimmed();
        if (text.isEmpty()) {
            return 0;
        }
        bool ok = false;
        double number = text.toDouble(&ok);
        return ok ? number : std::numeric_limits<double>::quiet_NaN();
    }
    default:
        return std::numeric_limits<double>::quiet_NaN();
    }
}

QString formatLocaleNumber(const QJsonValue & value) {
    return QLocale().toString(value.toDouble());
}

QVariant convertWithoutNulls(const QJsonValue & value) {
    if (value.isObject()) {
        return convertObjectWithoutNulls(value.toObject());
    }

    if (value.isArray()) {
        const QJsonArray array = value.toArray();
        QVariantList list;
        list.reserve(array.size());
        for (const QJsonValue & element : array) {
            list.append(convertWithoutNulls(element));
        }
        return list;
    }

    return value.toVariant();
}

QVariantMap convertObjectWithoutNulls(const QJsonObject & object) {
    QVariantMap map;
    for (auto it = object.constBegin(); it != object.constEnd(); ++it) {
        if (!it.value().isNull() && !it.value().isUndefined()) {
            map.insert(it.key(), convertWithoutNulls(it.value()));
        }
    }
    return map;
}

} // namespace JsonValues
