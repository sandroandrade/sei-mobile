#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <jni.h>
#include <QDebug>

#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL
  Java_br_edu_ifba_sei_MyJavaNatives_sendFibonaciResult(JNIEnv *env,
                                                    jobject obj,
                                                    jint n)
{
    qDebug() << "Computed fibonacci is:" << n;
}

#ifdef __cplusplus
}
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
