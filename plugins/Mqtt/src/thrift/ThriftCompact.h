#ifndef MQTT_THRIFT_COMPACT_H
#define MQTT_THRIFT_COMPACT_H

#include <QByteArray>
#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>
#include <QtGlobal>

namespace IGMQTT {
namespace Thrift {

// Thrift compact protocol type IDs
enum Type : quint8 {
    T_STOP = 0x00,
    T_TRUE = 0x01,
    T_FALSE = 0x02,
    T_BYTE = 0x03,
    T_INT16 = 0x04,
    T_INT32 = 0x05,
    T_INT64 = 0x06,
    T_DOUBLE = 0x07,
    T_BINARY = 0x08,
    T_LIST = 0x09,
    T_SET = 0x0A,
    T_MAP = 0x0B,
    T_STRUCT = 0x0C
};

/**
 * @brief Writer for Thrift compact protocol binary format.
 *
 * Implements the Thrift compact protocol encoding used by Instagram's
 * MQTToT (MQTT over Thrift) protocol for CONNECT payloads.
 */
class Writer {
public:
    Writer();

    // Struct operations
    void writeStructBegin();
    void writeStructEnd();

    // Field-level writes (auto field header)
    void writeBool(int fieldId, bool value);
    void writeByte(int fieldId, quint8 value);
    void writeInt16(int fieldId, qint16 value);
    void writeInt32(int fieldId, qint32 value);
    void writeInt64(int fieldId, qint64 value);
    void writeString(int fieldId, const QString & value);
    void writeBinary(int fieldId, const QByteArray & value);

    // List writes
    void writeListBegin(int fieldId, Type elementType, int size);
    void writeListInt32(int fieldId, const QVector<qint32> & values);
    void writeListString(int fieldId, const QStringList & values);

    // Map writes
    void writeMapBegin(int fieldId, Type keyType, Type valueType, int size);
    void writeMapStringString(int fieldId, const QMap<QString, QString> & map);

    // Nested struct field header (caller must writeStructBegin/End)
    void writeStructFieldBegin(int fieldId);

    // Get serialized data
    QByteArray data() const {
        return m_buffer;
    }

    // Reset
    void clear();

private:
    void writeFieldHeader(int fieldId, Type type);
    void writeVarint(quint64 value);
    void writeZigZag32(qint32 value);
    void writeZigZag64(qint64 value);
    void writeRawByte(quint8 byte);
    void writeRawBytes(const QByteArray & bytes);

    QByteArray m_buffer;
    QVector<int> m_lastFieldStack;
    int m_lastFieldId;
};

/**
 * @brief Reader for Thrift compact protocol binary format.
 *
 * Reads Thrift compact protocol encoded data, used for parsing
 * incoming MQTT payloads (GraphQL responses, Skywalker events, etc.)
 */
class Reader {
public:
    explicit Reader(const QByteArray & data);

    // Struct operations
    bool readStructBegin();
    void readStructEnd();

    // Read field header; returns false if STOP byte encountered
    bool readFieldHeader(int & fieldId, Type & fieldType);

    // Typed reads
    bool readBool();
    quint8 readByte();
    qint16 readInt16();
    qint32 readInt32();
    qint64 readInt64();
    double readDouble();
    QByteArray readBinary();
    QString readString();

    // Container reads
    int readListHeader(Type & elementType);
    int readMapHeader(Type & keyType, Type & valueType);

    // Skip a field of given type
    void skip(Type type);

    // State
    bool atEnd() const {
        return m_pos >= m_data.size();
    }
    int position() const {
        return m_pos;
    }

private:
    quint64 readVarint();
    qint32 fromZigZag32(quint32 n);
    qint64 fromZigZag64(quint64 n);
    quint8 readRawByte();

    QByteArray m_data;
    int m_pos;
    QVector<int> m_lastFieldStack;
    int m_lastFieldId;
    Type m_pendingBoolType; // for bool encoded in field header
};

} // namespace Thrift
} // namespace IGMQTT

#endif // MQTT_THRIFT_COMPACT_H
