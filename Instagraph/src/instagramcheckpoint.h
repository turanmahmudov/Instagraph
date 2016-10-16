#ifndef INSTAGRAMCHECKPOINT_H
#define INSTAGRAMCHECKPOINT_H

#include <QObject>
#include <QDir>
#include <QVariant>

class InstagramCheckPoint : public QObject
{
    Q_OBJECT

public:
    explicit InstagramCheckPoint(QObject *parent = 0);

public slots:
    void setUsername(QString username){this->m_username = username;}

private:
    QString m_username;
    QString m_token;

    QDir m_data_path;

signals:


private slots:

};

#endif // INSTAGRAMCHECKPOINT_H
