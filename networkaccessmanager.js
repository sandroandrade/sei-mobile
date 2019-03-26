var httpRequest = new XMLHttpRequest();
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
//    httpRequest.setDisableHeaderCheck(true);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    timer = Qt.createQmlObject("import QtQuick 2.12; Timer { interval: 20000; repeat: false; running: true }", Qt.application, "timeoutTimer");
    timer.triggered.connect(timeout)
    busyIndicator.running = true
    httpRequest.send()
}

function post(url, params) {
    httpRequest.open("POST", url);
//    httpRequest.setDisableHeaderCheck(true);
    httpRequest.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    httpRequest.setRequestHeader('Cookie', 'IFBA_SEI_sandroandrade_menu_mostrar=S;IFBA_SEI_sandroandrade_menu_tamanho_dados=79');
    timer = Qt.createQmlObject("import QtQuick 2.12; Timer { interval: 20000; repeat: false; running: true }", Qt.application, "timeoutTimer");
    timer.triggered.connect(timeout)
    busyIndicator.running = true
    httpRequest.send(params)
}
