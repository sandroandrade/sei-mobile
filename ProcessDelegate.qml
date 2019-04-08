import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "FontAwesome"

Frame {
    property string processId
    property string processType
    property string processSpecification
    property string processAssignment

    GridLayout {
        columns: 2
        Label { font.family: FontAwesome.solid; text: Icons.faIdCard; color: "#6c6c6c" }
        Label { id: idLabel; Layout.fillWidth: true; text: "Número: " + processId }

        Label { font.family: FontAwesome.solid; text: Icons.faListOl; color: "#6c6c6c" }
        Label { id: typeLabel; Layout.fillWidth: true; text: "Tipo: " + processType }

        Label { font.family: FontAwesome.solid; text: Icons.faInfoCircle; color: "#6c6c6c" }
        Label { id: specificationLabel; Layout.fillWidth: true; text: "Especificação: " + processSpecification }

        Label { font.family: FontAwesome.solid; text: Icons.faUserPlus; color: "#6c6c6c" }
        Label { id: assignmentLabel; Layout.fillWidth: true; text: "Atribuído a " + processAssignment }
    }
}
