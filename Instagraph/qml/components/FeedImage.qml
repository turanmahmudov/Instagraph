import QtQuick 2.12
import Lomiri.Components 1.3

Image {
    fillMode: Image.PreserveAspectCrop
    sourceSize: Qt.size(width,height)
    asynchronous: true
    cache: false // maybe false
    smooth: false
}
