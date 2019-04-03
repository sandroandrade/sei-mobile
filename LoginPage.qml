import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1

import br.edu.ifba.gsort.webscraping 1.0

import "networkaccessmanager.js" as NAM

Page {
    title: qsTr("Login")

    property Settings serverSettings

    WebScraper {
        source: "https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI"
        method: WebScraper.POST
        validator: "<title>:: SEI - Controle de Processos ::</title>"
        postData: {
            "hdnIdSistema": "100000100",
            "hdnMenuSistema": "",
            "hdnModuloSistema": "",
            "hdnSiglaOrgaoSistema": "IFBA",
            "hdnSiglaSistema": "SEI",
            "pwdSenha": txtPassword.text,
            "sbmLogin": "Acessar",
            "selOrgao": "0",
            "txtUsuario": txtUser.text
        }
        query: "//*[@id=\"selInfraUnidades\"]/option"
        onStatusChanged: {
            if (status === WebScraper.Ready)   console.log(payload)
            if (status === WebScraper.Error)   console.log(errorString())
            if (status === WebScraper.Invalid) console.log("Validator failed")
        }
        Component.onCompleted: load()
    }

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent

        TextField { id: txtUser; placeholderText: "login" }

        TextField { id: txtPassword; placeholderText: "password"; echoMode: TextInput.Password }

        Button {
            id: loginButton
            Layout.preferredWidth: parent.width
            text: "login"
            onClicked: login()
            Text {
                id: errorText
                color: "#607D8B"
                horizontalAlignment: Label.AlignHCenter
                anchors { horizontalCenter: parent.horizontalCenter; top: loginButton.bottom; topMargin: columnLayout.spacing }
            }
        }
    }

    Settings {
        id: userSettings
        property alias user: txtUser.text
        property alias password: txtPassword.text
    }

    Component.onCompleted: {
        if (Qt.platform.os != "android") txtUser.forceActiveFocus()
        if (userSettings.user !== "" && userSettings.password !== "") {
            txtUser.text = userSettings.user
            txtPassword.text = userSettings.password
            login()
        }
    }

    function login() {
        NAM.busyIndicator = busyIndicator
        NAM.errorText = errorText
        NAM.httpRequest.onreadystatechange=function() {
            if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                NAM.reset()
                var re1 = /<title>:: SEI - Controle de Processos ::<\/title>/
                if (re1.test(NAM.httpRequest.responseText)) {
                    var processedResponseText = NAM.httpRequest.responseText.replace(/&nbsp;/g, '').replace(/<!DOCTYPE.*>/g, '').replace(/<meta.*>/g, '').replace(/&/g, '&amp;');
                    if (Qt.platform.os == "android") {
                        configurator.username = txtUser.text
                        configurator.password = txtPassword.text
                    }
                    stackView.push("qrc:/MainPage.qml",
                                   {currentUser: txtUser.text,
                                    unitiesModelXml: processedResponseText,
                                    receivedModelXml: processedResponseText,
                                    generatedModelXml: processedResponseText,
                                    userSettings: userSettings,
                                    serverSettings: serverSettings
                                   })
                } else {
                    errorText.text = "acesso negado"
                }
            }
        }
        if (!serverSettings.serverURL.toLowerCase().startsWith('https://'))
            serverSettings.serverURL = 'https://' + serverSettings.serverURL.replace(/^http:\/\//gi, '')
        NAM.post(serverSettings.serverURL + '/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI',
                 'hdnIdSistema=100000100&hdnMenuSistema=&hdnModuloSistema=&hdnSiglaOrgaoSistema=IFBA&hdnSiglaSistema=SEI&pwdSenha=' + txtPassword.text + '&sbmLogin=Acessar&selOrgao=0&txtUsuario=' + txtUser.text)
    }

    StackView.onRemoved: {
        serverSettings.serverURL = ""
        serverSettings.siglaOrgaoSistema = ""
        serverSettings.siglaSistema = "SEI"
    }
}
