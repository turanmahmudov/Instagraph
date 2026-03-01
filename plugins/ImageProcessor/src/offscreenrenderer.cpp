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

#include "offscreenrenderer.h"

#include <QImage>
#include <QSurfaceFormat>
#include <QOpenGLFramebufferObject>
#include <QOpenGLFunctions>
#include <QQuickItem>

#include <QDebug>

#include <QQuickItemGrabResult>

// This *should* be the minimum amount of code necessary to render a QML Item offscreen
// (required by QQuickItem::grabToImage()) without showing any QWindow to the user.

OffscreenRenderer::OffscreenRenderer(QObject *parent)
    : QObject(parent)
    , m_renderControl(0)
    , m_window(0)
    , m_qmlEngine(0)
{
    qDebug() << Q_FUNC_INFO;

    m_renderControl = new QQuickRenderControl(this);
    m_window = new QQuickWindow(m_renderControl);
    m_qmlEngine = new QQmlEngine;

    if (!m_qmlEngine->incubationController())
        m_qmlEngine->setIncubationController(m_window->incubationController());

    emit contentItemChanged();
}

OffscreenRenderer::~OffscreenRenderer()
{
    delete m_renderControl;
    delete m_window;
    delete m_qmlEngine;
}

QQuickItem *OffscreenRenderer::contentItem() const
{
    if (!m_window)
        return 0;

    return m_window->contentItem();
}
