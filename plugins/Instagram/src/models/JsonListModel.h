#ifndef INSTAGRAM_JSONLISTMODEL_H
#define INSTAGRAM_JSONLISTMODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QJsonArray>
#include <QJsonObject>
#include <QStringList>
#include <QVariant>
#include <QVector>

class JsonListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    explicit JsonListModel(const QStringList & roleKeys, QObject * parent = nullptr);

    int rowCount(const QModelIndex & parent = QModelIndex()) const override;
    QVariant data(const QModelIndex & index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    using QObject::setProperty;

    Q_INVOKABLE QVariant get(int index) const;
    Q_INVOKABLE void setProperty(int index, const QString & role, const QVariant & value);
    Q_INVOKABLE void append(const QVariantMap & row);
    Q_INVOKABLE void insert(int index, const QVariantMap & row);
    Q_INVOKABLE void remove(int index, int count = 1);
    Q_INVOKABLE void clear();

    // Throws a JavaScript SyntaxError for invalid JSON, like JSON.parse
    Q_INVOKABLE QVariant parseResponse(const QString & json,
                                       const QStringList & itemPaths = QStringList());
    Q_INVOKABLE bool hasParsed(const QString & path) const;
    Q_INVOKABLE int countParsed(const QString & path) const;
    Q_INVOKABLE QVariant findParsed(const QString & path, int index) const;
    Q_INVOKABLE QVariant appendParsed(const QString & path, bool clear,
                                      const QVariantMap & options = QVariantMap());
    Q_INVOKABLE QVariant appendItems(const QVariantList & items, bool clear,
                                     const QVariantMap & options = QVariantMap());

signals:
    void countChanged();

protected:
    virtual QVariant mapItems(const QJsonArray & items, const QJsonObject & response,
                              const QVariantMap & options, bool clear,
                              QVector<QVariantMap> & rows) = 0;

    void insertMappedRows(int index, const QVector<QVariantMap> & rows);
    QJsonArray findParsedItems(const QString & path) const;

private:
    enum class RoleType { Unset, String, Number, Bool, Object };

    QVariant appendMappedItems(const QJsonArray & items, const QJsonObject & response,
                               const QVariantMap & options, bool clear);
    QVariantMap filterRoles(const QVariantMap & row) const;
    void recordRoleTypes(const QVariantMap & row);
    QVariant convertToRoleType(const QVariant & value, int keyIndex) const;

    QStringList m_roleKeys;
    QHash<int, QByteArray> m_roleNames;
    QVector<RoleType> m_roleTypes;
    QVector<QVariantMap> m_rows;
    QJsonObject m_response;
    QHash<QString, QJsonArray> m_parsedItems;
};

#endif // INSTAGRAM_JSONLISTMODEL_H
