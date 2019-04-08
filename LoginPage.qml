import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1

import br.edu.ifba.gsort.webscraping 1.0

Page {
    property Image busyIndicator
    property Settings serverSettings

    title: qsTr("Login")

    WebScraper {
        id: loginScraper
        method: WebScraper.POST
        validator: "<title>:: SEI - Controle de Processos ::</title>"
        onStatusChanged: {
            if (stackView.depth === 2) { // FIX ME
                if (status === WebScraper.Ready) {
                    if (Qt.platform.os == "android") {
                        configurator.username = txtUser.text
                        configurator.password = txtPassword.text
                    }
                    stackView.push("qrc:/MainPage.qml", {
                                       currentUser: txtUser.text,
                                       userSettings: userSettings,
                                       serverSettings: serverSettings,
                                       processesScraper: loginScraper
                                  })
                }
                if (status === WebScraper.Error)   errorText.text = errorString()
                if (status === WebScraper.Invalid) errorText.text = "acesso negado"
            }
        }
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

    function login() {
        loginScraper.source = "https://sei.ifba.edu.br/sip/login.php?sigla_orgao_sistema=IFBA\&sigla_sistema=SEI"
        loginScraper.postData = {
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
        loginScraper.load()
    }

    Settings {
        id: userSettings
        property alias user: txtUser.text
        property alias password: txtPassword.text
    }

    StackView.onRemoved: {
        serverSettings.serverURL = ""
        serverSettings.siglaOrgaoSistema = ""
        serverSettings.siglaSistema = "SEI"
    }

    Component.onCompleted: {
        busyIndicator.running = Qt.binding(function() { return loginScraper.status === WebScraper.Loading })
        if (Qt.platform.os != "android") txtUser.forceActiveFocus()
        if (userSettings.user !== "" && userSettings.password !== "") {
            txtUser.text = userSettings.user
            txtPassword.text = userSettings.password
            login()
        }
    }
}
