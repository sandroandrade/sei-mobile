import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "FontAwesome"

Frame {
    id: frame
    property string processId
    property string processType
    property string processSpecification
    property string processAssignment

    clip: true

    GridLayout {
        width: parent.width
        columns: 2

        Label { font.family: FontAwesome.solid; text: Icons.faIdCard; color: "#6c6c6c" }
        Label { Layout.fillWidth: true; text: "Número: " + processId }

        Label { font.family: FontAwesome.solid; text: Icons.faListOl; color: "#6c6c6c" }
        Label { Layout.fillWidth: true; text: "Tipo: " + processType }

        Label { id: iconLabel; font.family: FontAwesome.solid; text: Icons.faInfoCircle; color: "#6c6c6c" }
        Label { Layout.preferredWidth: parent.width - iconLabel.width - frame.padding; elide: Text.ElideRight; text: "Especificação: " + processSpecification }

        Label { font.family: FontAwesome.solid; text: Icons.faUserPlus; color: "#6c6c6c" }
        Label { Layout.fillWidth: true; text: "Atribuído a " + processAssignment }
    }
}
