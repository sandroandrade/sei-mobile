import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

import "networkaccessmanager.js" as NAM

ApplicationWindow {
    id: window
    visible: true
    width: 320
    height: 480
    title: qsTr("SEI Mobile")

    QtObject {
        id: internal
        property string hdnCaptcha
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 2 ? "\u25C0" : "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
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
        width: window.width * 0.66
        height: window.height
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
    }

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !busyIndicator.running
        initialItem: LoginPage {}
    }
}
