#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QLibrary>
#include <QtQml>
#include <QtQml/QQmlContext>

#include <src/instagram.h>
#include <src/imageprocessor.h>
#include <src/offscreenrenderer.h>
#include <src/cropimageprovider.h>
#include <src/cacheimage.h>

int main(int argc, char *argv[])
{
    setlocale(LC_ALL, "");

    QGuiApplication app(argc, argv);

    qmlRegisterType<Instagram>("Instagram",1,0,"Instagram");
    qmlRegisterType<ImageProcessor>("ImageProcessor",1,0,"ImageProcessor");
    qmlRegisterType<OffscreenRenderer>("OffscreenRenderer",1,0,"OffscreenRenderer");
    qmlRegisterType<CacheImage>("CacheImage",1,0,"CacheImage");

    QQuickView view;

    QQmlEngine *engine = view.engine();
    engine->addImageProvider(QLatin1String("photo"), new CropImageProvider);

    QObject::connect(engine, SIGNAL(quit()), QGuiApplication::instance(), SLOT(quit()));

    view.setSource(QUrl(QStringLiteral("qrc:///Main.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
