#ifndef MQTT_PLUGIN_H
#define MQTT_PLUGIN_H

#include <QQmlExtensionPlugin>

class MqttPlugin : public QQmlExtensionPlugin {
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char * uri) override;
};

#endif // MQTT_PLUGIN_H
