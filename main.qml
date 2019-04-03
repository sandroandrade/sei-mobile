import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Window 2.12

import "FontAwesome"

ApplicationWindow {
    id: window
    visible: true
    title: qsTr("SEI Mobile")
    visibility: "FullScreen"

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
        width: window.width * 0.66
        height: window.height
    }

    Image {
        id: busyIndicator

        property alias running: animation.running
        visible: running

        source: "qrc:///images/sei-logo.png"
        anchors.centerIn: parent
        width: Math.min(Screen.desktopAvailableWidth, Screen.desktopAvailableHeight)/4
        fillMode: Image.PreserveAspectFit
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
        initialItem: ServerConfigPage {}
    }
}
