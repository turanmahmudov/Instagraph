#ifndef IMAGEEDITOR_PLUGIN_H
#define IMAGEEDITOR_PLUGIN_H

#include <QQmlExtensionPlugin>

class ImageEditorPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *uri) override;
};

#endif // IMAGEEDITOR_PLUGIN_H
