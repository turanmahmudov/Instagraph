#include <QGuiApplication>
#include <QLibrary>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QtQml/QQmlContext>
#include <QtQml>

int main(int argc, char * argv[]) {
    setlocale(LC_ALL, "");

    QGuiApplication app(argc, argv);

    QQuickView view;

    QQmlEngine * engine = view.engine();

    // Content Hub works only in a Lomiri session. `clickable desktop` sets
    // CLICKABLE_DESKTOP_MODE; IS_DESKTOP overrides the detection.
    const QByteArray isDesktopEnv = qgetenv("IS_DESKTOP");
    const bool isDesktop = isDesktopEnv.isEmpty() ? qgetenv("CLICKABLE_DESKTOP_MODE") == "1"
                                                  : (isDesktopEnv == "1" || isDesktopEnv == "true");
    engine->rootContext()->setContextProperty("IS_DESKTOP", isDesktop);

    QObject::connect(engine, SIGNAL(quit()), QGuiApplication::instance(), SLOT(quit()));

    view.setSource(QUrl(QStringLiteral("qrc:///qml/Main.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}
