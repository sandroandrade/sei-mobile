import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.XmlListModel 2.12
import Qt.labs.settings 1.1

import "networkaccessmanager.js" as NAM

Page {
    property string currentUser
    property alias unitiesModelXml: unitiesModel.xml
    property alias receivedModelXml: receivedModel.xml
    property alias generatedModelXml: generatedModel.xml
    property Settings userSettings
    property Settings serverSettings

    title: qsTr("SEI Mobile - " + currentUser)

    Text {
        id: errorText
        color: "#607D8B"
        horizontalAlignment: Label.AlignHCenter
        anchors.centerIn: parent
    }

    ColumnLayout {
        anchors.fill: parent
        ComboBox {
            Layout.preferredWidth: parent.width
            model: XmlListModel {
                id: unitiesModel
                query: "//*[@id=\"selInfraUnidades\"]/option"
                XmlRole { name: "unity"; query: "string()" }
                XmlRole { name: "value"; query: "@value/string()" }
            }
            textRole: "unity"
            currentIndex: 0
            onCurrentIndexChanged: {
                NAM.busyIndicator = busyIndicator
                NAM.errorText = errorText
                NAM.httpRequest.onreadystatechange=function() {
                    console.log("Response headers: " + NAM.httpRequest.getAllResponseHeaders())
                    console.log("Response status: " + NAM.httpRequest.status)
                    console.log("Response state: " + NAM.httpRequest.readyState)
                    if (NAM.httpRequest.readyState === XMLHttpRequest.DONE && NAM.httpRequest.status != 0) {
                        NAM.reset()
                        var re = /<title>:: SEI - Controle de Processos ::<\/title>/
                        if (re.test(NAM.httpRequest.responseText)) {
                            var processedResponseText = NAM.httpRequest.responseText.replace(/&nbsp;/g, '').replace(/<!DOCTYPE.*>/g, '').replace(/<meta.*>/g, '').replace(/&/g, '&amp;');
                            receivedModelXml = processedResponseText
                            generatedModelXml = processedResponseText
                        } else {
                            errorText.text = "erro ao obter processos"
                        }
                    }
                }
                console.log("Unidade atual: " + internal.unidadeAtual)
                console.log("Nova unidade: " + model.get(currentIndex).value)
                console.log("Infra hash: " + internal.infraHash)
                NAM.post('https://sei.ifba.edu.br/sei/inicializar.php?infra_sistema=100000100&infra_unidade_atual=' + internal.unidadeAtual + '&infra_hash=' + internal.infraHash,
                         'selInfraUnidades=' + model.get(currentIndex).value)
            }
        }

        SwipeView {
            id: swipeView
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            ListView {
                model: receivedModel
                clip: true
                delegate: ItemDelegate {
                    width: parent.width
                    text: title
                    hoverEnabled: true
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: /infraTooltipMostrar\('(.*)','(.*)'\)/.exec(tooltip)[1]
                }
                XmlListModel {
                    id: receivedModel
                    query: "//*[@id=\"tblProcessosRecebidos\"]/tr[@class=\"infraTrClara\"]"
                    XmlRole { name: "title"; query: "td[1]/input/@title/string()" }
                    XmlRole { name: "tooltip"; query: "td[3]/a/@onmouseover/string()" }
                }
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            ListView {
                model: generatedModel
                clip: true
                delegate: ItemDelegate {
                    width: parent.width
                    text: title
                    hoverEnabled: true
                    ToolTip.delay: 1000
                    ToolTip.timeout: 5000
                    ToolTip.visible: hovered
                    ToolTip.text: /infraTooltipMostrar\('(.*)','(.*)'\)/.exec(tooltip)[1]
                }
                XmlListModel {
                    id: generatedModel
                    query: "//*[@id=\"tblProcessosGerados\"]/tr[@class=\"infraTrClara\"]"
                    XmlRole { name: "title"; query: "td[1]/input/@title/string()" }
                    XmlRole { name: "tooltip"; query: "td[3]/a/@onmouseover/string()" }
                }
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Received")
        }
        TabButton {
            text: qsTr("Generated")
        }
    }

    StackView.onRemoved: {
        userSettings.user = ""
        userSettings.password = ""
        if (Qt.platform.os == "android") {
            configurator.username = ""
            configurator.password = ""
        }
    }
}
