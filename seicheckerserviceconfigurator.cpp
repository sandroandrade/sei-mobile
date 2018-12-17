#include "seicheckerserviceconfigurator.h"

#include <QtAndroid>

SEICheckerServiceConfigurator::SEICheckerServiceConfigurator(QObject *parent) : QObject(parent)
{
    QAndroidJniObject context = QtAndroid::androidContext();
    QAndroidJniObject fileKey = QAndroidJniObject::fromString("br.edu.ifba.sei.PREFERENCE_FILE_KEY");
    _sharedPreferences = context.callObjectMethod(
                            "getSharedPreferences",
                            "(Ljava/lang/String;I)Landroid/content/SharedPreferences;",
                            fileKey.object<jstring>(),
                            0 // Context.MODE_PRIVATE
                        );
}

void SEICheckerServiceConfigurator::setUsername(const QString &username)
{
    QAndroidJniObject editor = _sharedPreferences.callObjectMethod("edit", "()Landroid/content/SharedPreferences$Editor;");
    editor.callObjectMethod("putString",
                      "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;",
                      QAndroidJniObject::fromString("sei-mobile-login").object<jstring>(),
                      QAndroidJniObject::fromString(username).object<jstring>()
                      );
    editor.callMethod<jboolean>("commit");
}

void SEICheckerServiceConfigurator::setPassword(const QString &password)
{
    QAndroidJniObject editor = _sharedPreferences.callObjectMethod("edit", "()Landroid/content/SharedPreferences$Editor;");
    editor.callObjectMethod("putString",
                      "(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;",
                      QAndroidJniObject::fromString("sei-mobile-password").object<jstring>(),
                      QAndroidJniObject::fromString(password).object<jstring>()
                      );
    editor.callMethod<jboolean>("commit");
}
