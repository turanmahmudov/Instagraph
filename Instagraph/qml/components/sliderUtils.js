/*
 * Copyright 2013-2015 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*!
  \qmltype sliderUtils
  \inqmlmodule Ubuntu.Components 1.3
  \ingroup ubuntu
  \brief Various sliding utility functions.
 */

.pragma library

/*!
  \qmlmethod sliderUtils::liveValue(item)
  The function returns the live value of the slider.
  */
function liveValue(item) {
    return item.__internals.liveValue;
}

/*!
  \qmlmethod sliderUtils::normalizedValue(item)
  The function returns the normalized live value of the slider.
  */
function normalizedValue(item) {
    return item.__internals.normalizedValue;
}

/*!
  \qmlmethod sliderUtils::isPressed(item)
  The function returns whether the slider is being pressed or not.
  */
function isPressed(item) {
    return item.__internals.isPressed;
}
