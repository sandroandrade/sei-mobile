import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.XmlListModel 2.12
import Qt.labs.settings 1.1

import br.edu.ifba.gsort.webscraping 1.0

import "networkaccessmanager.js" as NAM

Page {
    property string currentUser
    property Settings userSettings
    property Settings serverSettings
    property WebScraper processesScraper

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
            id: unityComboBox
            function findCurrentIndex() {
                var i;
                for (i = 0; i < comboBoxModel.count; ++i)
                    if (comboBoxModel.get(i).selected === "selected")
                        return i;
            }
            function handleCurrentIndexChanged() {
                if (currentIndex !== -1) {
                    processesScraper.source = serverSettings.serverURL + "/sei/inicializar.php"
                    processesScraper.postData = { "selInfraUnidades": unityComboBox.model.get(unityComboBox.currentIndex).value }
                    processesScraper.load()
                }
            }
            Layout.fillWidth: true
            Layout.margins: 10
            model: XmlListModel {
                id: comboBoxModel
                xml: processesScraper.payload
                query: "//*[@id=\"selInfraUnidades\"]/option"
                XmlRole { name: "unity"; query: "string()" }
                XmlRole { name: "value"; query: "@value/string()" }
                XmlRole { name: "selected"; query: "@selected/string()" }
                onStatusChanged: {
                    if (status === XmlListModel.Ready) {
                        unityComboBox.currentIndexChanged.disconnect(unityComboBox.handleCurrentIndexChanged)
                        unityComboBox.currentIndex = unityComboBox.findCurrentIndex()
                        unityComboBox.currentIndexChanged.connect(unityComboBox.handleCurrentIndexChanged)
                    }
                }
            }
            textRole: "unity"
        }

        SwipeView {
            id: swipeView
            Layout.preferredWidth: parent.width
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            Component {
                id: processDelegate
                ProcessDelegate {
                    anchors { left: parent.left; leftMargin: 10; right: parent.right; rightMargin: 10 }
                    processId: id
                    processType: /infraTooltipMostrar\('(.*)','(.*)'\)/.exec(typeAndSpecification)[2]
                    processSpecification: /infraTooltipMostrar\('(.*)','(.*)'\)/.exec(typeAndSpecification)[1]
                    processAssignment: assignedTo
                }
            }

            ListView {
                clip: true
                spacing: 10
                model: XmlListModel {
                    xml: processesScraper.payload
                    query: "//*[@id=\"tblProcessosRecebidos\"]/tr[@class=\"infraTrClara\"]"
                    XmlRole { name: "id"; query: "td[1]/input/@title/string()" }
                    XmlRole { name: "typeAndSpecification"; query: "td[3]/a/@onmouseover/string()" }
                    XmlRole { name: "assignedTo"; query: "td[4]/a/string()" }
                }
                delegate: processDelegate
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            ListView {
                clip: true
                spacing: 10
                model: XmlListModel {
                    xml: processesScraper.payload
                    query: "//*[@id=\"tblProcessosGerados\"]/tr[@class=\"infraTrClara\"]"
                    XmlRole { name: "id"; query: "td[1]/input/@title/string()" }
                    XmlRole { name: "typeAndSpecification"; query: "td[3]/a/@onmouseover/string()" }
                    XmlRole { name: "assignedTo"; query: "td[4]/a/string()" }
                }
                delegate: processDelegate
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton { text: "Recebidos" }
        TabButton { text: "Gerados" }
    }

    StackView.onRemoved: {
        userSettings.user = ""
        userSettings.password = ""
        if (Qt.platform.os == "android") {
            configurator.username = ""
            configurator.password = ""
        }
    }

    Component.onCompleted: {
        busyIndicator.running = Qt.binding(function() { return processesScraper.status === WebScraper.Loading })
    }
}
