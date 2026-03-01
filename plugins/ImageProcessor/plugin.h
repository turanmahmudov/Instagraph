#ifndef IMAGEPROCESSOR_PLUGIN_H
#define IMAGEPROCESSOR_PLUGIN_H

#include <QQmlExtensionPlugin>

class ImageProcessorPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
    void initializeEngine(QQmlEngine *engine, const char *uri) override;
};

#endif // IMAGEPROCESSOR_PLUGIN_H
