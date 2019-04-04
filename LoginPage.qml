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
        //query: "//*[@id=\"selInfraUnidades\"]/option"
        onStatusChanged: {
            if (status === WebScraper.Ready) {
                if (Qt.platform.os == "android") {
                    configurator.username = txtUser.text
                    configurator.password = txtPassword.text
                }
                stackView.push("qrc:/MainPage.qml",
                               {currentUser: txtUser.text,
                                unitiesModelXml: payload,
                                receivedModelXml: payload,
                                generatedModelXml: payload,
                                userSettings: userSettings,
                                serverSettings: serverSettings
                               })
            }
            if (status === WebScraper.Error)   errorText.text = errorString()
            if (status === WebScraper.Invalid) errorText.text = "acesso negado"
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
            onClicked: loginScraper.load()

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
            loginScraper.load()
        }
    }
}
