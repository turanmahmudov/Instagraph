/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

#include <src/cropimageprovider.h>

#include <QUrl>
#include <QUrlQuery>
#include <QDebug>

// CropImageResponse

CropImageResponse::CropImageResponse(const QString &filePath, const QRectF &cropRect, const QString &errorString)
    : m_errorString(errorString)
{
    if (m_image.load(filePath)) {
        m_image = m_image.copy(cropRect.x() * m_image.width(),
                               cropRect.y() * m_image.height(),
                               cropRect.width() * m_image.width(),
                               cropRect.height() * m_image.height());
    } else {
        m_errorString = "Cannot load image";
    }

    QMetaObject::invokeMethod(this, "finished", Qt::QueuedConnection);
}

QString CropImageResponse::errorString() const
{
    return m_errorString;
}

QQuickTextureFactory *CropImageResponse::textureFactory() const
{
    //if (!m_errorString.isEmpty())
      //  return nullptr;

    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

// CropImageProvider

QQuickImageResponse *CropImageProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);

    QString filePath = QUrl(id).path();
    QRectF cropArea;
    QString errorString;

    //qDebug() << "Requested image to provider." << "\nFile path is:" << filePath << "\nQueries:" << QUrlQuery(id).queryItems();

    if (!QUrlQuery(id).hasQueryItem("x") || !QUrlQuery(id).hasQueryItem("x") || !QUrlQuery(id).hasQueryItem("x") || !QUrlQuery(id).hasQueryItem("x")) {
        qWarning() << Q_FUNC_INFO << "Request not valid. A default crop rect will be used.";
        cropArea = QRectF(0.0, 0.0, 1.0, 1.0);
    } else {
        qreal x = QUrlQuery(id).queryItemValue("x").toFloat();
        qreal y = QUrlQuery(id).queryItemValue("y").toFloat();
        qreal w = QUrlQuery(id).queryItemValue("w").toFloat();
        qreal h = QUrlQuery(id).queryItemValue("h").toFloat();

        cropArea = QRectF(x, y, w, h);
    }

    return new CropImageResponse(filePath, cropArea, errorString);
}
