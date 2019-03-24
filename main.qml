import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import "networkaccessmanager.js" as NAM

import "FontAwesome"

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
        Material.foreground: "white"
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            font.family: FontAwesome.regular
            text: Icons.faAddressCard
            onClicked: {
                if (stackView.depth > 1)
                    stackView.pop()
                else
                    drawer.open()
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
        running: false
    }

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !busyIndicator.running
        initialItem: ServerConfigPage {}
    }
}
