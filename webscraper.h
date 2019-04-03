#ifndef WEBSCRAPER_H
#define WEBSCRAPER_H

#include <QObject>
#include <QUrl>
#include <QVariantMap>

class WebScraper : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(Method method READ method WRITE setMethod NOTIFY methodChanged)
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QVariantMap postData READ postData WRITE setPostData NOTIFY postDataChanged)
    Q_PROPERTY(QString validator READ validator WRITE setValidator NOTIFY validatorChanged)
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(QString payload READ payload NOTIFY payloadChanged)

public:
    explicit WebScraper(QObject *parent = nullptr);

    enum Status { Null = 0, Ready, Loading, Error, Invalid };
    Q_ENUM(Status)
    Status status() const;

    enum Method { GET = 0, POST };
    Q_ENUM(Method)
    Method method() const;
    void setMethod(Method method);

    QString source() const;
    void setSource(QString &source);

    QVariantMap postData() const;
    void setPostData(const QVariantMap &postData);

    QString validator() const;
    void setValidator(const QString &validator);

    QString query() const;
    void setQuery(const QString &query);

    QString payload() const;

    Q_INVOKABLE QString errorString() const;
    Q_INVOKABLE void load();

Q_SIGNALS:
    void statusChanged(WebScraper::Status);
    void methodChanged(WebScraper::Method);
    void sourceChanged();
    void postDataChanged();
    void validatorChanged();
    void queryChanged();
    void payloadChanged();

private Q_SLOTS:
    void networkReplyFinished();

private:
    void setStatus(Status status);
    QByteArray createPostData() const;
    void startRequest();
    void tidyPayload();
    void evaluateQuery();

private:
    Status _status;
    Method _method;
    QString _source;
    QVariantMap _postData;
    QString _validator;
    QString _query;
    QString _payload;
    QString _errorString;
};

#endif // WEBSCRAPER_H
