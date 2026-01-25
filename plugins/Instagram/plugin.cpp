#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "src/api/Instagram.h"

void InstagramPlugin::registerTypes(const char *uri) {
    // @uri Instagram
    
    // Register Instagram as a creatable type
    // Usage in QML: Instagram { id: instagram }
    qmlRegisterType<Instagram>(uri, 1, 0, "Instagram");
    
    // Alternatively, register as singleton (only one instance):
    // qmlRegisterSingletonType<Instagram>(uri, 1, 0, "Instagram", 
    //     [](QQmlEngine*, QJSEngine*) -> QObject* { return new Instagram; });
}
