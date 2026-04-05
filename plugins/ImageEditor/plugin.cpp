#include <QtQml/QQmlContext>
#include <QtQml>

#include "plugin.h"
#include "src/ImageEditor.h"

void ImageEditorPlugin::registerTypes(const char * uri) {
    // @uri ImageEditor
    qmlRegisterType<ImageEditor>(uri, 1, 0, "ImageEditor");
}
