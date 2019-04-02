var httpRequest = new XMLHttpRequest()
httpRequest.withCredentials = true
var busyIndicator
var errorText
var timer

function reset() {
    timer.stop()
    timer.destroy()
    busyIndicator.running = false
    errorText.text = ""
}

function timeout() {
    httpRequest.abort()
    timer.stop()
    timer.destroy()
    busyIndicator.running = false
    errorText.text = "erro de timeout\nsem conexão ou servidor SEI indisponível"
}

function get(url) {
    httpRequest.open("GET", url);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    timer = Qt.createQmlObject("import QtQuick 2.12; Timer { interval: 20000; repeat: false; running: true }", Qt.application, "timeoutTimer");
    timer.triggered.connect(timeout)
    busyIndicator.running = true
    httpRequest.send()
}

function post(url, params) {
    httpRequest.open("POST", url);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    timer = Qt.createQmlObject("import QtQuick 2.12; Timer { interval: 20000; repeat: false; running: true }", Qt.application, "timeoutTimer");
    timer.triggered.connect(timeout)
    busyIndicator.running = true
    httpRequest.send(params)
}
