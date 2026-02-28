#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "src/InstagramMqtt.h"

void MqttPlugin::registerTypes(const char *uri) {
    // @uri InstagramMqtt
    
    // Register InstagramMqtt as a creatable type
    // Usage in QML: InstagramMqtt { id: mqtt }
    qmlRegisterType<InstagramMqtt>(uri, 1, 0, "InstagramMqtt");
}
