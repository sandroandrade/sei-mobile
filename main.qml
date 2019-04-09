import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12
import QtQuick.Window 2.12

import br.edu.ifba.gsort.webscraping 1.0

import "FontAwesome"

ApplicationWindow {
    id: window
    visible: true
    title: qsTr("SEI Mobile")
    visibility: "FullScreen"

    WebScraper {
        id: webScraper
        method: WebScraper.POST
        defaultProtocol: "https"
        validator: "<title>:: SEI - Controle de Processos ::</title>"
    }

    header: ToolBar {
        Material.foreground: "white"
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            font { family: FontAwesome.solid }
            text: stackView.depth > 1 ? Icons.faChevronLeft : Icons.faBars
            onClicked: {
                if (stackView.depth > 1) stackView.pop()
                else drawer.open()
            }
        }

        Label {
            text: stackView.currentItem.title
            font.bold: true
            anchors.centerIn: parent
        }
    }

    Drawer {
        id: drawer
        width: window.width * ((Screen.desktopAvailableWidth < Screen.desktopAvailableHeight) ? 2/3:1/3)
        height: window.height

        ColumnLayout {
            width: parent.width
            ItemDelegate {
                Layout.fillWidth: true
                text: "Meus processos"
                onClicked: {
                    webScraper.source = serverSettings.serverURL + "/sip/login.php?sigla_orgao_sistema=" + serverSettings.siglaOrgaoSistema + "\&sigla_sistema=" + serverSettings.siglaSistema
                    webScraper.postData = {
                        "hdnIdSistema": "100000100",
                        "hdnMenuSistema": "",
                        "hdnModuloSistema": "",
                        "hdnSiglaOrgaoSistema": serverSettings.siglaOrgaoSistema,
                        "hdnSiglaSistema": serverSettings.siglaSistema,
                        "pwdSenha": txtPassword.text,
                        "sbmLogin": "Acessar",
                        "selOrgao": "0",
                        "txtUsuario": txtUser.text
                    }
                    webScraper.load()
                }
            }
       }
    }

    Image {
        id: busyIndicator

        property alias running: animation.running

        visible: running
        source: "qrc:///images/sei-logo.png"
        anchors.centerIn: parent
        width: Math.min(Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)/4
        fillMode: Image.PreserveAspectFit
        running: webScraper.status === WebScraper.Loading

        SequentialAnimation on scale {
            id: animation
            NumberAnimation { from: 1.0; to: 1.1; duration: 500 }
            NumberAnimation { from: 1.1; to: 1.0; duration: 500 }
            loops: Animation.Infinite
            running: false
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !busyIndicator.running
        initialItem: ServerConfigPage {
            busyIndicator: busyIndicator
            webScraper: webScraper
        }
    }
}
