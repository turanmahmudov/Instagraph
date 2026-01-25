#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QLibrary>
#include <QtQml>
#include <QtQml/QQmlContext>

#include "src/imageprocessor.h"
#include "src/offscreenrenderer.h"
#include "src/cropimageprovider.h"
#include "src/cacheimage.h"

int main(int argc, char *argv[])
{
    setlocale(LC_ALL, "");

    QGuiApplication app(argc, argv);

    // Instagram is now a QML plugin - it registers itself automatically
    // when QML imports "Instagram 1.0". No need to register here.
    
    qmlRegisterType<ImageProcessor>("ImageProcessor",1,0,"ImageProcessor");
    qmlRegisterType<OffscreenRenderer>("OffscreenRenderer",1,0,"OffscreenRenderer");
    qmlRegisterType<CacheImage>("CacheImage",1,0,"CacheImage");

    QQuickView view;

    QQmlEngine *engine = view.engine();
    engine->addImageProvider(QLatin1String("photo"), new CropImageProvider);

    engine->rootContext()->setContextProperty("IS_DESKTOP", qgetenv("IS_DESKTOP"));

    QObject::connect(engine, SIGNAL(quit()), QGuiApplication::instance(), SLOT(quit()));

    view.setSource(QUrl(QStringLiteral("qrc:///qml/Main.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
