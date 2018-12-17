#ifndef SEICHECKERSERVICECONFIGURATOR_H
#define SEICHECKERSERVICECONFIGURATOR_H

#include <QObject>

#include <QtAndroidExtras/QAndroidJniObject>

class SEICheckerServiceConfigurator : public QObject
{
    Q_OBJECT
    Q_PROPERTY (QString username WRITE setUsername)
    Q_PROPERTY (QString password WRITE setPassword)

public:
    explicit SEICheckerServiceConfigurator(QObject *parent = nullptr);

    void setUsername(const QString &username);
    void setPassword(const QString &password);

private:
    QAndroidJniObject _sharedPreferences;
};

#endif // SEICHECKERSERVICECONFIGURATOR_H
