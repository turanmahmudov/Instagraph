#ifndef INSTAGRAM_PLUGIN_H
#define INSTAGRAM_PLUGIN_H

#include <QQmlExtensionPlugin>

class InstagramPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char * uri) override;
};

#endif // INSTAGRAM_PLUGIN_H
