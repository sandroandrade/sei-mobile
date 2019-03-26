import QtQuick 2.11
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

    title: qsTr("SEI Mobile - " + currentUser)

    ColumnLayout {
        anchors.fill: parent
        ComboBox {
            Layout.preferredWidth: parent.width
            model: unitiesModel
            textRole: "unity"
            currentIndex: 0
            XmlListModel {
                id: unitiesModel
                query: "//*[@id=\"selInfraUnidades\"]/option"
                XmlRole { name: "unity"; query: "string()" }
                XmlRole { name: "value"; query: "@value/string()" }
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
