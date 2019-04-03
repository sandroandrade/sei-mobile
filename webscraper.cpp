#include "webscraper.h"

#include <QNetworkReply>
#include <QQmlContext>
#include <QRegularExpression>
#include <QUrlQuery>
#include <QXmlQuery>

#include "qqmlengine.h"

#include <buffio.h>
#include <tidy.h>

WebScraper::WebScraper(QObject *parent)
    : QObject(parent),
      _status(WebScraper::Null),
      _method(WebScraper::GET)
{
}

WebScraper::Status WebScraper::status() const
{
    return _status;
}

WebScraper::Method WebScraper::method() const
{
    return _method;
}

void WebScraper::setMethod(WebScraper::Method method)
{
    if (_method != method) {
        _method = method;
        emit methodChanged(_method);
    }
}

QString WebScraper::source() const
{
    return _source;
}

void WebScraper::setSource(QString &source)
{
    if (_source != source) {
        if (!source.toLower().startsWith("http")) {
            source = "http://" + source;
        }
        _source = source;
        emit sourceChanged();
    }
}

QVariantMap WebScraper::postData() const
{
    return _postData;
}

void WebScraper::setPostData(const QVariantMap &postData)
{
    if (_postData != postData) {
        _postData = postData;
        emit postDataChanged();
    }
}

QString WebScraper::validator() const
{
    return _validator;
}

void WebScraper::setValidator(const QString &validator)
{
    if (_validator != validator) {
        _validator = validator;
        emit validatorChanged();
    }
}

QString WebScraper::query() const
{
    return _query;
}

void WebScraper::setQuery(const QString &query)
{
    if (_query != query) {
        _query = query;
        emit queryChanged();
    }
}

QString WebScraper::payload() const
{
    return _payload;
}

QString WebScraper::errorString() const
{
    return _errorString;
}

void WebScraper::load()
{
    setStatus(WebScraper::Null);
    _payload.clear();
    _errorString.clear();

    if (_source.isEmpty()) {
        _errorString = QStringLiteral("Cannot perform request. Source is empty!");
        setStatus(WebScraper::Error);
        return;
    }

    setStatus(WebScraper::Loading);
    startRequest();
}

void WebScraper::networkReplyFinished()
{
    auto reply = dynamic_cast<QNetworkReply *>(sender());

    if (reply->error() != QNetworkReply::NoError) {
        _errorString = reply->errorString();
        setStatus(WebScraper::Error);
        reply->deleteLater();
        return;
    }

    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    switch (statusCode) {
        case 200: {
            _payload = reply->readAll();
            if (!_validator.isEmpty() && !QRegularExpression(_validator).match(_payload).hasMatch()) {
                _errorString = QStringLiteral("Validator '%1' failed!").arg(_validator);
                setStatus(WebScraper::Invalid);
            }
            else {
                tidyPayload();
                if (!_query.isEmpty()) {
                    evaluateQuery();
                } else {
                    setStatus(WebScraper::Ready);
                }
            }
            break;
        }
        case 302: {
            _source = QUrl(_source).resolved(QUrl(reply->rawHeader("Location"))).toString();
            startRequest();
            break;
        }
        default: {
            _errorString = QStringLiteral("WebScraper finished with status code %1").arg(statusCode);
            setStatus(WebScraper::Error);
            break;
        }
    }
    reply->deleteLater();
}

void WebScraper::setStatus(WebScraper::Status status)
{
    if (_status != status) {
        _status = status;
        emit statusChanged(_status);
    }
}

QByteArray WebScraper::createPostData() const
{
    QUrlQuery urlQuery;
    for (auto const& [key, val] : _postData.toStdMap()) {
        urlQuery.addQueryItem(QString(key), val.toString());
    }

    return urlQuery.toString(QUrl::FullyEncoded).toUtf8();
}

void WebScraper::startRequest()
{
    QNetworkRequest request(_source);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    if (_method == WebScraper::GET) {
        QNetworkReply *reply = qmlContext(this)->engine()->networkAccessManager()->get(request);
        connect (reply, &QNetworkReply::finished, this, &WebScraper::networkReplyFinished);
    }
    if (_method == WebScraper::POST) {
        QNetworkReply *reply = qmlContext(this)->engine()->networkAccessManager()->post(request, createPostData());
        connect (reply, &QNetworkReply::finished, this, &WebScraper::networkReplyFinished);
    }
}

void WebScraper::tidyPayload()
{
    TidyDoc tdoc = tidyCreate();
    tidyOptSetBool(tdoc, TidyXmlOut, yes);
    tidyOptSetBool(tdoc, TidyQuiet, yes);
    tidyOptSetBool(tdoc, TidyNumEntities, yes);
    tidyOptSetBool(tdoc, TidyShowWarnings, no);

    tidyParseString(tdoc, _payload.toUtf8());
    tidyCleanAndRepair(tdoc);
    TidyBuffer output = {nullptr, nullptr, 0, 0, 0};
    tidySaveBuffer(tdoc, &output);
    _payload = QString(reinterpret_cast<char*>(output.bp));
}

void WebScraper::evaluateQuery()
{
    QXmlQuery query;

    query.setFocus(_payload);
    query.setQuery(_query);

    if (!query.isValid()) {
        _errorString = QStringLiteral("Query '%1' is invalid!").arg(_query);
        setStatus(WebScraper::Invalid);

        return;
    }

    query.evaluateTo(&_payload);
    setStatus(WebScraper::Ready);
}
