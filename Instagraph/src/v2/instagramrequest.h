#ifndef INSTAGRAMREQUEST_H
#define INSTAGRAMREQUEST_H

#include <QNetworkReply>
#include <QObject>

#include "constants.h"

class InstagramRequest : public QObject
{
    Q_OBJECT
public:
    explicit InstagramRequest(QNetworkReply *reply, QObject *parent = 0);

    static QString generateSignature(QJsonObject data);
    QString buildBody(QList<QList<QString> > bodies, QString boundary);

private:
    QNetworkReply *m_reply;

Q_SIGNALS:
    void replyStringReady(QVariant ans);

public Q_SLOTS:

private Q_SLOTS:
    void finishGetUrl();
};

#endif // INSTAGRAMREQUEST_H
