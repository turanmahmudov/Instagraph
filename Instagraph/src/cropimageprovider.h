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

#ifndef CROPIMAGEPROVIDER_H
#define CROPIMAGEPROVIDER_H

// For QQuickAsyncImageProvider
#include <QtQuick/qquickimageprovider.h>

#include <QImage>

class CropImageResponse : public QQuickImageResponse
{
public:
    CropImageResponse(const QString &filePath, const QRectF &cropRect, const QString &errorString);

    QString errorString() const override;
    QQuickTextureFactory * textureFactory() const override;

private:
    QString m_errorString;
    QImage m_image;
};

class CropImageProvider : public QQuickAsyncImageProvider
{
public:
    QQuickImageResponse *requestImageResponse(const QString & id, const QSize & requestedSize);
};

#endif // CROPIMAGEPROVIDER_H
