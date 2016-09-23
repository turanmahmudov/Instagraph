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

#ifndef OFFSCREENRENDERER_H
#define OFFSCREENRENDERER_H

#include <QObject>
#include <QQuickRenderControl>
#include <QQuickWindow>
#include <QQmlEngine>
#include <QQuickItem>
#include <QOpenGLContext>
#include <QOffscreenSurface>
#include <QOpenGLFramebufferObject>

class OffscreenRenderer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem* contentItem READ contentItem NOTIFY contentItemChanged)

public:
    explicit OffscreenRenderer(QObject *parent = 0);
    ~OffscreenRenderer();

    QQuickItem* contentItem() const;

signals:
    void contentItemChanged();

public slots:

private:
    QQuickRenderControl* m_renderControl;
    QQuickWindow* m_window;
    QQmlEngine* m_qmlEngine;
};

#endif // OFFSCREENRENDERER_H
