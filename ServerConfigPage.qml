import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.settings 1.1

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
            onClicked: stackView.push("qrc:/LoginPage.qml", {serverSettings: serverSettings})
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
        if (Qt.platform.os != "android")
            txtServerURL.forceActiveFocus()
        if (serverSettings.serverURL !== "" && serverSettings.siglaOrgaoSistema !== "") {
            txtServerURL.text = serverSettings.serverURL
            txtSiglaOrgaoSistema.text = serverSettings.siglaOrgaoSistema
            txtSiglaSistema.text = serverSettings.siglaSistema
            stackView.push("qrc:/LoginPage.qml", {serverSettings: serverSettings})
        }
    }
}
