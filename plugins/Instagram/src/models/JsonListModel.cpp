#include "JsonListModel.h"

#include <QJSEngine>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QtDebug>

namespace {

QJsonValue findValue(const QJsonObject & object, const QStringList & keys) {
    QJsonObject current = object;
    for (int i = 0; i < keys.size() - 1; ++i) {
        current = current.value(keys.at(i)).toObject();
    }
    return current.value(keys.last());
}

void removePath(QJsonObject & object, const QStringList & keys, int depth) {
    const QString & key = keys.at(depth);
    if (depth == keys.size() - 1) {
        object.remove(key);
        return;
    }

    if (!object.value(key).isObject()) {
        return;
    }

    QJsonObject child = object.value(key).toObject();
    removePath(child, keys, depth + 1);
    object.insert(key, child);
}

} // namespace

JsonListModel::JsonListModel(const QStringList & roleKeys, QObject * parent)
    : QAbstractListModel(parent), m_roleKeys(roleKeys), m_roleTypes(roleKeys.size()) {
    for (int i = 0; i < m_roleKeys.size(); ++i) {
        m_roleNames.insert(Qt::UserRole + 1 + i, m_roleKeys.at(i).toUtf8());
    }
}

int JsonListModel::rowCount(const QModelIndex & parent) const {
    return parent.isValid() ? 0 : m_rows.size();
}

QVariant JsonListModel::data(const QModelIndex & index, int role) const {
    int keyIndex = role - Qt::UserRole - 1;
    if (!index.isValid() || index.row() >= m_rows.size() || keyIndex < 0 ||
        keyIndex >= m_roleKeys.size()) {
        return QVariant();
    }
    return convertToRoleType(m_rows.at(index.row()).value(m_roleKeys.at(keyIndex)), keyIndex);
}

QHash<int, QByteArray> JsonListModel::roleNames() const {
    return m_roleNames;
}

int JsonListModel::count() const {
    return m_rows.size();
}

QVariant JsonListModel::get(int index) const {
    if (index < 0 || index >= m_rows.size()) {
        return QVariant();
    }
    QVariantMap row;
    for (int i = 0; i < m_roleKeys.size(); ++i) {
        QVariant value = convertToRoleType(m_rows.at(index).value(m_roleKeys.at(i)), i);
        if (value.isValid()) {
            row.insert(m_roleKeys.at(i), value);
        }
    }
    return row;
}

void JsonListModel::setProperty(int index, const QString & role, const QVariant & value) {
    int keyIndex = m_roleKeys.indexOf(role);
    if (index < 0 || index >= m_rows.size() || keyIndex < 0) {
        qWarning() << "JsonListModel::setProperty: no role" << role << "at index" << index;
        return;
    }

    m_rows[index].insert(role, value);
    recordRoleTypes(m_rows.at(index));
    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, {Qt::UserRole + 1 + keyIndex});
}

void JsonListModel::append(const QVariantMap & row) {
    insertMappedRows(m_rows.size(), {row});
}

void JsonListModel::insert(int index, const QVariantMap & row) {
    if (index < 0 || index > m_rows.size()) {
        qWarning() << "JsonListModel::insert: index out of range" << index;
        return;
    }
    insertMappedRows(index, {row});
}

void JsonListModel::remove(int index, int count) {
    if (index < 0 || count < 1 || index + count > m_rows.size()) {
        qWarning() << "JsonListModel::remove: range out of range" << index << count;
        return;
    }

    beginRemoveRows(QModelIndex(), index, index + count - 1);
    m_rows.remove(index, count);
    endRemoveRows();
    emit countChanged();
}

void JsonListModel::clear() {
    if (m_rows.isEmpty()) {
        return;
    }

    beginRemoveRows(QModelIndex(), 0, m_rows.size() - 1);
    m_rows.clear();
    endRemoveRows();
    emit countChanged();
}

QVariant JsonListModel::parseResponse(const QString & json, const QStringList & itemPaths) {
    m_response = QJsonObject();
    m_parsedItems.clear();

    QJsonParseError error;
    QJsonDocument document = QJsonDocument::fromJson(json.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        QJSEngine * engine = qjsEngine(this);
        if (engine) {
            engine->throwError(QJSValue::SyntaxError,
                               QStringLiteral("JSON.parse: ") + error.errorString());
        }
        return QVariant();
    }

    if (!document.isObject()) {
        return document.toVariant();
    }

    m_response = document.object();
    QJsonObject fields = m_response;
    for (const QString & path : itemPaths) {
        const QStringList keys = path.split(QLatin1Char('.'));
        QJsonValue items = findValue(m_response, keys);
        if (items.isArray()) {
            m_parsedItems.insert(path, items.toArray());
        }
        removePath(fields, keys, 0);
    }
    return fields.toVariantMap();
}

bool JsonListModel::hasParsed(const QString & path) const {
    return m_parsedItems.contains(path);
}

int JsonListModel::countParsed(const QString & path) const {
    return m_parsedItems.value(path).size();
}

QVariant JsonListModel::findParsed(const QString & path, int index) const {
    const QJsonArray items = m_parsedItems.value(path);
    if (index < 0 || index >= items.size()) {
        return QVariant();
    }
    return items.at(index).toVariant();
}

QVariant JsonListModel::appendParsed(const QString & path, bool clear,
                                     const QVariantMap & options) {
    return appendMappedItems(m_parsedItems.value(path), m_response, options, clear);
}

QVariant JsonListModel::appendItems(const QVariantList & items, bool clear,
                                    const QVariantMap & options) {
    return appendMappedItems(QJsonArray::fromVariantList(items), QJsonObject(), options, clear);
}

QJsonArray JsonListModel::findParsedItems(const QString & path) const {
    return m_parsedItems.value(path);
}

void JsonListModel::insertMappedRows(int index, const QVector<QVariantMap> & rows) {
    if (rows.isEmpty()) {
        return;
    }

    beginInsertRows(QModelIndex(), index, index + rows.size() - 1);
    for (int i = 0; i < rows.size(); ++i) {
        QVariantMap row = filterRoles(rows.at(i));
        recordRoleTypes(row);
        m_rows.insert(index + i, row);
    }
    endInsertRows();
    emit countChanged();
}

QVariant JsonListModel::appendMappedItems(const QJsonArray & items, const QJsonObject & response,
                                          const QVariantMap & options, bool clear) {
    QVector<QVariantMap> rows;
    QVariant extras = mapItems(items, response, options, clear, rows);
    if (clear) {
        this->clear();
    }
    insertMappedRows(m_rows.size(), rows);
    return extras;
}

QVariantMap JsonListModel::filterRoles(const QVariantMap & row) const {
    QVariantMap filtered;
    for (auto it = row.constBegin(); it != row.constEnd(); ++it) {
        if (m_roleKeys.contains(it.key())) {
            filtered.insert(it.key(), it.value());
        }
    }
    return filtered;
}

void JsonListModel::recordRoleTypes(const QVariantMap & row) {
    for (auto it = row.constBegin(); it != row.constEnd(); ++it) {
        int keyIndex = m_roleKeys.indexOf(it.key());
        if (keyIndex < 0 || m_roleTypes.at(keyIndex) != RoleType::Unset) {
            continue;
        }

        switch (static_cast<QMetaType::Type>(it.value().type())) {
        case QMetaType::QString:
            m_roleTypes[keyIndex] = RoleType::String;
            break;
        case QMetaType::Bool:
            m_roleTypes[keyIndex] = RoleType::Bool;
            break;
        case QMetaType::Int:
        case QMetaType::UInt:
        case QMetaType::LongLong:
        case QMetaType::ULongLong:
        case QMetaType::Double:
            m_roleTypes[keyIndex] = RoleType::Number;
            break;
        case QMetaType::QVariantMap:
        case QMetaType::QVariantList:
            m_roleTypes[keyIndex] = RoleType::Object;
            break;
        default:
            break;
        }
    }
}

QVariant JsonListModel::convertToRoleType(const QVariant & value, int keyIndex) const {
    QMetaType::Type type = static_cast<QMetaType::Type>(value.type());
    switch (m_roleTypes.at(keyIndex)) {
    case RoleType::String:
        return type == QMetaType::QString ? value : QVariant(QString(""));
    case RoleType::Bool:
        return type == QMetaType::Bool ? value : QVariant(false);
    case RoleType::Number:
        if (type == QMetaType::Int || type == QMetaType::UInt || type == QMetaType::LongLong ||
            type == QMetaType::ULongLong || type == QMetaType::Double) {
            return value;
        }
        return QVariant(0.0);
    case RoleType::Object:
        return type == QMetaType::QVariantMap || type == QMetaType::QVariantList ? value
                                                                                  : QVariant();
    default:
        return QVariant();
    }
}
