#include <QGuiApplication>
#include <QQmlApplicationEngine>

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QQmlContext>
#include "seicheckerserviceconfigurator.h"
#endif

#include "webscraper.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QGuiApplication::setOrganizationName("ifba");
    QGuiApplication::setOrganizationDomain("ifba.edu.br");
    QGuiApplication::setApplicationName("sei-mobile");

    qmlRegisterType<WebScraper>("br.edu.ifba.gsort.webscraping", 1, 0, "WebScraper");

    QQmlApplicationEngine engine;

#ifdef Q_OS_ANDROID
    engine.rootContext()->setContextProperty("configurator", new SEICheckerServiceConfigurator(&engine));
    QAndroidJniObject::callStaticMethod<void>("br/edu/ifba/sei/SEICheckerJobService",
                                                  "startMyService",
                                                  "(Landroid/content/Context;)V",
                                                  QtAndroid::androidActivity().object());
#endif

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return -1;
}

    return QGuiApplication::exec();
}
