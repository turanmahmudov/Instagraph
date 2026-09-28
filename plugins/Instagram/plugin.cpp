#include <QtQml/QQmlContext>
#include <QtQml>

#include "plugin.h"
#include "src/api/Instagram.h"
#include "src/media/MediaCache.h"

void InstagramPlugin::registerTypes(const char * uri) {
    // @uri Instagram

    // Register Instagram as a creatable type
    // Usage in QML: Instagram { id: instagram }
    qmlRegisterType<Instagram>(uri, 1, 0, "Instagram");
    qmlRegisterType<MediaCache>(uri, 1, 0, "MediaCache");

    // Alternatively, register as singleton (only one instance):
    // qmlRegisterSingletonType<Instagram>(uri, 1, 0, "Instagram",
    //     [](QQmlEngine*, QJSEngine*) -> QObject* { return new Instagram; });
}
