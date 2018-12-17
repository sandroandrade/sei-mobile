import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "networkaccessmanager.js" as NAM

Page {
    title: qsTr("SEI Mobile - Login")
    ColumnLayout {
        id: columnLayout
        enabled: false
        anchors.centerIn: parent
        TextField { id: txtUser; placeholderText: "login" }
        TextField { id: txtPassword; placeholderText: "password"; echoMode: TextInput.Password }
        Button {
            id: loginButton
            Layout.preferredWidth: parent.width
            text: "login"
            onClicked: {
                NAM.httpRequest.onreadystatechange=function() {
                    if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                        NAM.reset()
                        var re = /<title>:: SEI - Controle de Processos ::<\/title>/
                        if (re.test(NAM.httpRequest.responseText)) {
                            var processedResponseText = NAM.httpRequest.responseText.replace(/&nbsp;/g, '').replace(/<!DOCTYPE.*>/g, '').replace(/<meta.*>/g, '').replace(/&/g, '&amp;');
                            stackView.push("qrc:/MainPage.qml",
                                           {currentUser: txtUser.text,
                                            unitiesModelXml: processedResponseText,
                                            receivedModelXml: processedResponseText,
                                            generatedModelXml: processedResponseText
                                           })
                            if (Qt.platform.os == "android") {
                                configurator.username = txtUser.text
                                configurator.password = txtPassword.text
                            }
                        } else {
                            errorText.text = "acesso negado"
                        }
                    }
                }
                NAM.post('https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI',
                         'hdnCaptcha=' + internal.hdnCaptcha + '&hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=' + txtPassword.text + '&sbmLogin=Acessar&selOrgao=0&txtUsuario=' + txtUser.text)
            }
            Text {
                id: errorText
                color: "#607D8B"
                horizontalAlignment: Label.AlignHCenter
                anchors { horizontalCenter: parent.horizontalCenter; top: loginButton.bottom; topMargin: columnLayout.spacing }
            }
        }
    }
    Component.onCompleted: {
        NAM.busyIndicator = busyIndicator
        NAM.errorText = errorText
        NAM.httpRequest.onreadystatechange=function() {
            if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                NAM.reset()
                var re = /name="hdnCaptcha".*value="(.*)"/
                if (re.test(NAM.httpRequest.responseText)) {
                    internal.hdnCaptcha = re.exec(NAM.httpRequest.responseText)[1]
                    columnLayout.enabled = true
                } else {
                    errorText.text = "erro ao obter captcha"
                }
            }
        }
        NAM.get('https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA&sigla_sistema=SEI')
    }
}
