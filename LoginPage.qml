import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "networkaccessmanager.js" as NAM

Page {
    title: qsTr("SEI Mobile - Login")
    ColumnLayout {
        anchors.centerIn: parent
        TextField { id: txtUser; placeholderText: "login" }
        TextField { id: txtPassword; placeholderText: "password"; echoMode: TextInput.Password }
        Button {
            Layout.preferredWidth: parent.width
            text: "login"
            onClicked: {
                NAM.httpRequest.onreadystatechange=function() {
                    if (NAM.httpRequest.readyState === XMLHttpRequest.DONE &&
                            NAM.httpRequest.status === 200) {
                        busyIndicator.running = false
                        var processedResponseText = NAM.httpRequest.responseText.replace(/&nbsp;/g, '').replace(/<!DOCTYPE.*>/g, '').replace(/<meta.*>/g, '').replace(/&/g, '&amp;');
                        stackView.push("qrc:/MainPage.qml",
                                       {currentUser: txtUser.text,
                                        unitiesModelXml: processedResponseText,
                                        receivedModelXml: processedResponseText,
                                        generatedModelXml: processedResponseText
                                       })
                    }
                }
                NAM.post('https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI',
                         'hdnCaptcha=' + internal.hdnCaptcha + '&hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=' + txtPassword.text + '&sbmLogin=Acessar&selOrgao=0&txtUsuario=' + txtUser.text)
                busyIndicator.running = true
            }
        }
    }
}
