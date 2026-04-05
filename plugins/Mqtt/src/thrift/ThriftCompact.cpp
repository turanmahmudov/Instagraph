#include "ThriftCompact.h"
#include <QDebug>

namespace IGMQTT {
namespace Thrift {

// ============================================================
// Writer
// ============================================================

Writer::Writer() : m_lastFieldId(0) {}

void Writer::clear() {
    m_buffer.clear();
    m_lastFieldStack.clear();
    m_lastFieldId = 0;
}

void Writer::writeStructBegin() {
    m_lastFieldStack.push_back(m_lastFieldId);
    m_lastFieldId = 0;
}

void Writer::writeStructEnd() {
    writeRawByte(T_STOP);
    if (!m_lastFieldStack.isEmpty()) {
        m_lastFieldId = m_lastFieldStack.takeLast();
    }
}

void Writer::writeFieldHeader(int fieldId, Type type) {
    int delta = fieldId - m_lastFieldId;
    if (delta > 0 && delta <= 15) {
        writeRawByte(static_cast<quint8>((delta << 4) | type));
    } else {
        writeRawByte(type);
        writeZigZag32(static_cast<qint32>(fieldId));
    }
    m_lastFieldId = fieldId;
}

void Writer::writeBool(int fieldId, bool value) {
    writeFieldHeader(fieldId, value ? T_TRUE : T_FALSE);
}

void Writer::writeByte(int fieldId, quint8 value) {
    writeFieldHeader(fieldId, T_BYTE);
    writeRawByte(value);
}

void Writer::writeInt16(int fieldId, qint16 value) {
    writeFieldHeader(fieldId, T_INT16);
    writeZigZag32(static_cast<qint32>(value));
}

void Writer::writeInt32(int fieldId, qint32 value) {
    writeFieldHeader(fieldId, T_INT32);
    writeZigZag32(value);
}

void Writer::writeInt64(int fieldId, qint64 value) {
    writeFieldHeader(fieldId, T_INT64);
    writeZigZag64(value);
}

void Writer::writeString(int fieldId, const QString & value) {
    QByteArray utf8 = value.toUtf8();
    writeFieldHeader(fieldId, T_BINARY);
    writeVarint(static_cast<quint64>(utf8.size()));
    writeRawBytes(utf8);
}

void Writer::writeBinary(int fieldId, const QByteArray & value) {
    writeFieldHeader(fieldId, T_BINARY);
    writeVarint(static_cast<quint64>(value.size()));
    writeRawBytes(value);
}

void Writer::writeListBegin(int fieldId, Type elementType, int size) {
    writeFieldHeader(fieldId, T_LIST);
    if (size <= 14) {
        writeRawByte(static_cast<quint8>((size << 4) | elementType));
    } else {
        writeRawByte(static_cast<quint8>(0xF0 | elementType));
        writeVarint(static_cast<quint64>(size));
    }
}

void Writer::writeListInt32(int fieldId, const QVector<qint32> & values) {
    writeListBegin(fieldId, T_INT32, values.size());
    for (qint32 v : values) {
        writeZigZag32(v);
    }
}

void Writer::writeListString(int fieldId, const QStringList & values) {
    writeListBegin(fieldId, T_BINARY, values.size());
    for (const QString & s : values) {
        QByteArray utf8 = s.toUtf8();
        writeVarint(static_cast<quint64>(utf8.size()));
        writeRawBytes(utf8);
    }
}

void Writer::writeMapBegin(int fieldId, Type keyType, Type valueType, int size) {
    writeFieldHeader(fieldId, T_MAP);
    if (size == 0) {
        writeRawByte(0);
    } else {
        writeVarint(static_cast<quint64>(size));
        writeRawByte(static_cast<quint8>((keyType << 4) | valueType));
    }
}

void Writer::writeMapStringString(int fieldId, const QMap<QString, QString> & map) {
    writeMapBegin(fieldId, T_BINARY, T_BINARY, map.size());
    for (auto it = map.constBegin(); it != map.constEnd(); ++it) {
        QByteArray key = it.key().toUtf8();
        QByteArray val = it.value().toUtf8();
        writeVarint(static_cast<quint64>(key.size()));
        writeRawBytes(key);
        writeVarint(static_cast<quint64>(val.size()));
        writeRawBytes(val);
    }
}

void Writer::writeStructFieldBegin(int fieldId) {
    writeFieldHeader(fieldId, T_STRUCT);
    // Caller must call writeStructBegin() after this
}

void Writer::writeVarint(quint64 value) {
    while (true) {
        if ((value & ~static_cast<quint64>(0x7F)) == 0) {
            writeRawByte(static_cast<quint8>(value & 0xFF));
            break;
        } else {
            writeRawByte(static_cast<quint8>((value & 0x7F) | 0x80));
            value >>= 7;
        }
    }
}

void Writer::writeZigZag32(qint32 value) {
    quint32 encoded = static_cast<quint32>((value << 1) ^ (value >> 31));
    writeVarint(static_cast<quint64>(encoded));
}

void Writer::writeZigZag64(qint64 value) {
    quint64 encoded = static_cast<quint64>((value << 1) ^ (value >> 63));
    writeVarint(encoded);
}

void Writer::writeRawByte(quint8 byte) {
    m_buffer.append(static_cast<char>(byte));
}

void Writer::writeRawBytes(const QByteArray & bytes) {
    m_buffer.append(bytes);
}

// ============================================================
// Reader
// ============================================================

Reader::Reader(const QByteArray & data)
    : m_data(data), m_pos(0), m_lastFieldId(0), m_pendingBoolType(T_STOP) {}

bool Reader::readStructBegin() {
    m_lastFieldStack.push_back(m_lastFieldId);
    m_lastFieldId = 0;
    return true;
}

void Reader::readStructEnd() {
    if (!m_lastFieldStack.isEmpty()) {
        m_lastFieldId = m_lastFieldStack.takeLast();
    }
}

bool Reader::readFieldHeader(int & fieldId, Type & fieldType) {
    if (atEnd())
        return false;

    quint8 byte = readRawByte();
    if (byte == T_STOP)
        return false;

    int delta = (byte & 0xF0) >> 4;
    fieldType = static_cast<Type>(byte & 0x0F);

    if (delta == 0) {
        // Absolute field ID (zigzag encoded)
        fieldId = fromZigZag32(static_cast<quint32>(readVarint()));
    } else {
        fieldId = m_lastFieldId + delta;
    }
    m_lastFieldId = fieldId;

    // For booleans, the value is in the type nibble
    if (fieldType == T_TRUE || fieldType == T_FALSE) {
        m_pendingBoolType = fieldType;
    }

    return true;
}

bool Reader::readBool() {
    if (m_pendingBoolType != T_STOP) {
        bool val = (m_pendingBoolType == T_TRUE);
        m_pendingBoolType = T_STOP;
        return val;
    }
    return readRawByte() == 1;
}

quint8 Reader::readByte() {
    return readRawByte();
}

qint16 Reader::readInt16() {
    return static_cast<qint16>(fromZigZag32(static_cast<quint32>(readVarint())));
}

qint32 Reader::readInt32() {
    return fromZigZag32(static_cast<quint32>(readVarint()));
}

qint64 Reader::readInt64() {
    return fromZigZag64(readVarint());
}

double Reader::readDouble() {
    if (m_pos + 8 > m_data.size())
        return 0.0;
    double val;
    memcpy(&val, m_data.constData() + m_pos, 8);
    m_pos += 8;
    return val;
}

QByteArray Reader::readBinary() {
    int length = static_cast<int>(readVarint());
    if (length <= 0 || m_pos + length > m_data.size()) {
        return QByteArray();
    }
    QByteArray result = m_data.mid(m_pos, length);
    m_pos += length;
    return result;
}

QString Reader::readString() {
    return QString::fromUtf8(readBinary());
}

int Reader::readListHeader(Type & elementType) {
    quint8 byte = readRawByte();
    int size = (byte >> 4) & 0x0F;
    elementType = static_cast<Type>(byte & 0x0F);
    if (size == 0x0F) {
        size = static_cast<int>(readVarint());
    }
    return size;
}

int Reader::readMapHeader(Type & keyType, Type & valueType) {
    int size = static_cast<int>(readVarint());
    if (size > 0) {
        quint8 types = readRawByte();
        keyType = static_cast<Type>((types >> 4) & 0x0F);
        valueType = static_cast<Type>(types & 0x0F);
    } else {
        keyType = T_STOP;
        valueType = T_STOP;
    }
    return size;
}

void Reader::skip(Type type) {
    switch (type) {
    case T_TRUE:
    case T_FALSE:
        readBool();
        break;
    case T_BYTE:
        readRawByte();
        break;
    case T_INT16:
    case T_INT32:
    case T_INT64:
        readVarint();
        break;
    case T_DOUBLE:
        m_pos += 8;
        break;
    case T_BINARY:
        readBinary();
        break;
    case T_LIST:
    case T_SET: {
        Type elemType;
        int size = readListHeader(elemType);
        for (int i = 0; i < size; ++i) {
            skip(elemType);
        }
        break;
    }
    case T_MAP: {
        Type kType, vType;
        int size = readMapHeader(kType, vType);
        for (int i = 0; i < size; ++i) {
            skip(kType);
            skip(vType);
        }
        break;
    }
    case T_STRUCT: {
        readStructBegin();
        int fid;
        Type ftype;
        while (readFieldHeader(fid, ftype)) {
            skip(ftype);
        }
        readStructEnd();
        break;
    }
    default:
        break;
    }
}

quint64 Reader::readVarint() {
    quint64 result = 0;
    int shift = 0;
    while (m_pos < m_data.size()) {
        quint8 byte = readRawByte();
        result |= static_cast<quint64>(byte & 0x7F) << shift;
        if ((byte & 0x80) == 0)
            break;
        shift += 7;
    }
    return result;
}

qint32 Reader::fromZigZag32(quint32 n) {
    return static_cast<qint32>((n >> 1) ^ -(static_cast<qint32>(n & 1)));
}

qint64 Reader::fromZigZag64(quint64 n) {
    return static_cast<qint64>((n >> 1) ^ -(static_cast<qint64>(n & 1)));
}

quint8 Reader::readRawByte() {
    if (m_pos >= m_data.size())
        return 0;
    return static_cast<quint8>(m_data.at(m_pos++));
}

} // namespace Thrift
} // namespace IGMQTT
