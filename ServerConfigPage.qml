import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1

import "networkaccessmanager.js" as NAM

Page {
    title: qsTr("Configuração do Servidor")

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 20
        width: parent.width*0.75

        ColumnLayout {
            Layout.preferredWidth: parent.width
            spacing: 2
            Label { text: "URL do servidor:" }
            SEITextField {
                id: txtServerURL
                Layout.preferredWidth: parent.width
                placeholderText: "ex: sei.ifba.edu.br"
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width
            spacing: 2
            Label { text: "Sigla do órgão:" }
            SEITextField {
                id: txtSiglaOrgaoSistema
                Layout.preferredWidth: parent.width
                placeholderText: "verifique na URL"
            }
        }

        ColumnLayout {
            Layout.preferredWidth: parent.width
            spacing: 2
            Label { text: "Sigla do sistema:" }
            SEITextField {
                id: txtSiglaSistema
                Layout.preferredWidth: parent.width
                text: "SEI"
            }
        }

        Button {
            id: loginButton
            Layout.fillWidth: true
            text: "avançar"
            onClicked: getCaptcha()
            Text {
                id: errorText
                color: "#607D8B"
                horizontalAlignment: Label.AlignHCenter
                anchors { horizontalCenter: parent.horizontalCenter; top: loginButton.bottom; topMargin: columnLayout.spacing }
            }
        }
    }

    Settings {
        id: serverSettings
        property alias serverURL: txtServerURL.text
        property alias siglaOrgaoSistema: txtSiglaOrgaoSistema.text
        property alias siglaSistema: txtSiglaSistema.text
    }

    Component.onCompleted: {
        if (serverSettings.serverURL !== "" && serverSettings.siglaOrgaoSistema !== "") {
            txtServerURL.text = serverSettings.serverURL
            txtSiglaOrgaoSistema.text = serverSettings.siglaOrgaoSistema
            txtSiglaSistema.text = serverSettings.siglaSistema
            getCaptcha()
        }
    }

    function getCaptcha() {
        NAM.busyIndicator = busyIndicator
        NAM.errorText = errorText
        NAM.httpRequest.onreadystatechange=function() {
            if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                NAM.reset()
                var re = /name="hdnCaptcha".*value="(.*)"/
                if (re.test(NAM.httpRequest.responseText)) {
                    internal.hdnCaptcha = re.exec(NAM.httpRequest.responseText)[1]
                    console.log("PUSHING")
                    stackView.push("qrc:/LoginPage.qml", {serverSettings: serverSettings})
                } else {
                    errorText.text = "erro ao obter captcha\nverifique os dados acima"
                }
            }
        }
        if (!txtServerURL.text.toLowerCase().startsWith('https://'))
            txtServerURL.text = 'https://' + txtServerURL.text.replace(/^http:\/\//gi, '')
        NAM.get(txtServerURL.text + '/sip/login.php?sigla_orgao_sistema=' + txtSiglaOrgaoSistema.text + '&sigla_sistema=' + txtSiglaSistema.text)
    }
}
