#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QQmlContext>
#include "seicheckerserviceconfigurator.h"
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    app.setOrganizationName("ifba");
    app.setOrganizationDomain("ifba.edu.br");
    app.setApplicationName("sei-mobile");

    QQmlApplicationEngine engine;

#ifdef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("configurator", new SEICheckerServiceConfigurator(&engine));
    QAndroidJniObject::callStaticMethod<void>("br/edu/ifba/sei/SEICheckerJobService",
                                                  "startMyService",
                                                  "(Landroid/content/Context;)V",
                                                  QtAndroid::androidActivity().object());
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
