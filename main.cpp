#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QLibrary>
#include <QtQml>
#include <QtQml/QQmlContext>

int main(int argc, char *argv[])
{
    setlocale(LC_ALL, "");

    QGuiApplication app(argc, argv);

    // All QML types (Instagram, ImageEditor, ImageProcessor) are now
    // registered by their respective QML plugins automatically.

    QQuickView view;

    QQmlEngine *engine = view.engine();

    engine->rootContext()->setContextProperty("IS_DESKTOP", qgetenv("IS_DESKTOP"));

    QObject::connect(engine, SIGNAL(quit()), QGuiApplication::instance(), SLOT(quit()));

    view.setSource(QUrl(QStringLiteral("qrc:///qml/Main.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
