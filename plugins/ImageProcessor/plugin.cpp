#include <QtQml>
#include <QtQml/QQmlContext>
#include <QQmlEngine>

#include "plugin.h"
#include "src/imageprocessor.h"
#include "src/cropimageprovider.h"

void ImageProcessorPlugin::registerTypes(const char *uri) {
    // @uri ImageProcessor
    qmlRegisterType<ImageProcessor>(uri, 1, 0, "ImageProcessor");
}

void ImageProcessorPlugin::initializeEngine(QQmlEngine *engine, const char *uri) {
    Q_UNUSED(uri);
    engine->addImageProvider(QLatin1String("photo"), new CropImageProvider);
}
